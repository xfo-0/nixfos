{ lib, ... }:
{
  den.aspects.tailscale = {
    settings = {
      options.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable tailscale on this host.";
      };
      options.tags = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        example = [ "tag:prod" ];
        description = ''
          ACL tags to advertise on join. The auth key referenced by authKeySecret
          must be authorized for these tags (created as a tagged key, or by a user
          listed in the tailnet policy's tagOwners). Empty = untagged device owned
          by the authenticating identity.
        '';
      };
      options.authKeySecret = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "tailscale/authkey";
        description = ''
          sops secret name (in <host>/tailscale.yaml) holding a reusable tailscale
          auth key for unattended join on first boot. null = join interactively
          with `tailscale up`.
        '';
      };
      options.acceptDns = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Accept the tailnet's pushed DNS config (MagicDNS). true lets tailscale
          own DNS; with "Override local DNS" set tailnet-side this funnels ALL
          queries through MagicDNS (100.100.100.100). false keeps the host's own
          resolver (router/systemd-resolved) for everything — set on servers that
          don't need to resolve *.ts.net names and shouldn't depend on MagicDNS.
        '';
      };
    };

    tailnet-grant =
      { host, ... }:
      lib.optional ((host.settings.tailscale.enable or false) && (host.settings.tailscale.tags or [ ]) != [ ]) {
        from = "fleet";
        ports = "*";
      };

    nixos =
      {
        host,
        config,
        ...
      }:
      let
        cfg = host.settings.tailscale or { };
        tags = cfg.tags or [ ];
        authKeySecret = cfg.authKeySecret or null;
        secretRoot = host.secretPath or null;
        sopsFile = if secretRoot == null then null else "${secretRoot}/tailscale.yaml";
        useAuthKey = authKeySecret != null && sopsFile != null;
      in
      lib.mkIf (cfg.enable or false) (lib.mkMerge [
        {
          services.tailscale = {
            enable = true;
            openFirewall = true;
            useRoutingFeatures = "client";
            extraUpFlags = lib.optional (
              tags != [ ]
            ) "--advertise-tags=${lib.concatStringsSep "," tags}";
            extraSetFlags = [
              "--accept-dns=${lib.boolToString (cfg.acceptDns or true)}"
            ]
            ++ lib.optional (host.primaryUser != null) "--operator=${host.primaryUser}";
          };
          networking.firewall.trustedInterfaces = [ "tailscale0" ];
        }
        (lib.mkIf useAuthKey {
          sops.secrets.${authKeySecret}.sopsFile = sopsFile;
          services.tailscale.authKeyFile = config.sops.secrets.${authKeySecret}.path;
        })
      ]);

    persist =
      { host, ... }:
      let
        cfg = host.settings.tailscale or { };
      in
      {
        directories = lib.optionals (cfg.enable or false) [
          {
            directory = "/var/lib/tailscale";
            mode = "0700";
          }
        ];
      };
  };
}
