{ lib, inputs, ... }:
{
  flake-file.inputs.ncro.url = "gh:manic-systems/ncro";

  den.aspects.services.binary-cache.ncro = {
    settings = {
      options.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable ncro local route-optimizing cache proxy on this host.";
      };
      options.listen = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1:8080";
        description = "Address ncro binds to; also where local nix substitutes from.";
      };
      options.fallbackSubstituters = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "https://cache.nixos.org" ];
        description = "Substituters used directly if ncro is unavailable. Kept after local ncro in the list.";
      };
    };

    nixos =
      {
        host,
        binary-caches,
        ...
      }:
      let
        cfg = host.settings.services.binary-cache.ncro or { };
        listen = cfg.listen or "127.0.0.1:8080";
        fallbackSubstituters = cfg.fallbackSubstituters or [ "https://cache.nixos.org" ];
        selfPort = host.settings.services.binary-cache.harmonia.port or 5000;
        selfUrl = if host.ip == null then null else "http://${host.ip}:${toString selfPort}";
        byKind = k: lib.filter (s: (s.kind or "") == k) binary-caches;
        peerUpstreams = lib.pipe (byKind "harmonia") [
          (lib.filter (s: s ? url && s.url != selfUrl && (s.publicKey or "") != ""))
          (map (s: {
            inherit (s) url;
            public_key = s.publicKey;
          }))
        ];
        ncpsUpstreams = lib.pipe (byKind "ncps") [
          (lib.filter (s: s ? url))
          (map (
            s:
            {
              inherit (s) url;
              priority = 5;
            }
            // lib.optionalAttrs ((s.publicKey or "") != "") { public_key = s.publicKey; }
          ))
        ];
        externalUpstreams = lib.pipe (lib.unique (byKind "external")) [
          (lib.filter (s: s ? url))
          (map (
            s:
            {
              inherit (s) url;
            }
            // lib.optionalAttrs ((s.publicKey or "") != "") { public_key = s.publicKey; }
          ))
        ];
        baseUpstreams = [
          {
            url = "https://cache.nixos.org";
            priority = 10;
          }
        ];
        listenUrl = "http://${listen}";
      in
      {
        imports = [ inputs.ncro.nixosModules.ncro ];

        config = lib.mkIf (cfg.enable or false) {
          services.ncro = {
            enable = true;
            settings = {
              server.listen = listen;
              upstreams = baseUpstreams ++ ncpsUpstreams ++ peerUpstreams ++ externalUpstreams;
            };
          };

          nix.settings.substituters = lib.mkBefore ([ listenUrl ] ++ fallbackSubstituters);
        };
      };
  };
}
