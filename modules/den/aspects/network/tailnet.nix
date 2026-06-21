{
  den,
  lib,
  collectors,
  ...
}:
let
  fleetTag = "tag:prod";

  devices = {
    pixel = "100.104.13.40";
    redmi = "100.122.37.121";
  };
  deviceNames = builtins.attrNames devices;

  allHosts = lib.concatMap (sys: lib.attrValues (den.hosts.${sys} or { })) (
    builtins.attrNames (den.hosts or { })
  );
  advertisedTags = lib.unique (lib.concatMap (h: h.settings.tailscale.tags or [ ]) allHosts);
  tagOwners = lib.genAttrs advertisedTags (_: [ "autogroup:admin" ]);

  resolveGrant =
    g:
    let
      inherit (g) ports;
      fleetDst = [ "${fleetTag}:${ports}" ];
    in
    {
      fleet = [
        {
          action = "accept";
          src = [ fleetTag ];
          dst = fleetDst;
        }
      ];
      devices = [
        {
          action = "accept";
          src = deviceNames;
          dst = fleetDst;
        }
      ];
      mesh = [
        {
          action = "accept";
          src = [ fleetTag ] ++ deviceNames;
          dst = fleetDst ++ map (n: "${n}:${ports}") deviceNames;
        }
      ];
    }
    .${g.from} or [ ];

  kdeConnectMesh = {
    from = "mesh";
    ports = "1714-1764";
  };

  buildPolicy = grants: {
    inherit tagOwners;
    hosts = devices;
    acls = lib.unique (lib.concatMap resolveGrant (lib.unique ([ kdeConnectMesh ] ++ grants)));
    tests = map (name: {
      src = name;
      accept = [ "${fleetTag}:443" ];
      deny = [ "${fleetTag}:22" ];
    }) deviceNames;
  };
in
{
  den.quirks.tailnet-grant.desc = "Tailscale ACL grant fragments { from = \"fleet\"|\"devices\"|\"mesh\"; ports; } emitted by aspects that expose a tailnet surface; collected at fleet scope and compiled into the tailnet policy.";

  den.policies.collect-tailnet-grants = collectors.collectAllHosts "tailnet-grant";

  den.schema.host.includes = [ den.policies.collect-tailnet-grants ];

  den.aspects.tailnet = {
    nixos =
      {
        host,
        pkgs,
        tailnet-grant,
        ...
      }:
      let
        aclFile = pkgs.writeText "tailnet-acl.json" (builtins.toJSON (buildPolicy tailnet-grant));
        push = pkgs.writeShellApplication {
          name = "tailnet-acl";
          runtimeInputs = with pkgs; [
            curl
            jq
            sops
            ssh-to-age
          ];
          text = ''
            acl=${aclFile}
            if [ "''${1:-apply}" = show ]; then
              jq . "$acl"
              exit 0
            fi
            sops_file="''${NX:-$HOME/nx}/.secrets/common/tailscale-api.yaml"
            SOPS_AGE_KEY="$(ssh-to-age -private-key -i "$HOME/.ssh/id_ed25519")"
            export SOPS_AGE_KEY
            cid="$(sops decrypt --extract '["client_id"]' "$sops_file")"
            csec="$(sops decrypt --extract '["client_secret"]' "$sops_file")"
            tok="$(printf 'grant_type=client_credentials&client_id=%s&client_secret=%s' "$cid" "$csec" \
              | curl -fsS --data @- https://api.tailscale.com/api/v2/oauth/token \
              | jq -r .access_token)"
            curl -fsS -X POST \
              -H "Authorization: Bearer $tok" \
              -H "Content-Type: application/json" \
              --data-binary @"$acl" \
              https://api.tailscale.com/api/v2/tailnet/-/acl
          '';
        };
      in
      lib.mkIf (host.primaryUser != null && (host.settings.tailscale.enable or false)) {
        environment.systemPackages = [ push ];
      };
  };
}
