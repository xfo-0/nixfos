{ lib, ... }:
{
  den.aspects.services.binary-cache.ncps = {
    settings = {
      options.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable ncps cache service on this host.";
      };
      options.hostName = lib.mkOption {
        type = lib.types.str;
        default = "ncps.local";
        description = "Public hostname for this cache (used in signatures and substituter URLs).";
      };
      options.dataPath = lib.mkOption {
        type = lib.types.str;
        default = "/var/cache/ncps";
        description = "Local cache storage path.";
      };
      options.bind = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1:8501";
        description = "Address ncps server binds to.";
      };
      options.port = lib.mkOption {
        type = lib.types.port;
        default = 8501;
      };
      options.upstreamCaches = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "https://cache.nixos.org" ];
        description = "Upstream caches to proxy. Local builds bypass ncps — only pulls flow through it.";
      };
      options.upstreamPublicKeys = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
        description = "Public keys trusted for upstream signature validation.";
      };
      options.secretKeyPath = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "Ed25519 secret key for re-signing served paths. null = serve unsigned.";
      };
      options.openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };

    binary-caches =
      { host, ... }:
      let
        cfg = host.settings.services.binary-cache.ncps or { };
      in
      lib.optionalAttrs ((cfg.enable or false) && host.ip != null) {
        url = "http://${host.ip}:${toString (cfg.port or 8501)}";
        publicKey = "";
        kind = "ncps";
      };

    nixos =
      { host, binary-caches, ... }:
      let
        cfg = host.settings.services.binary-cache.ncps or { };
        externals = lib.unique (lib.filter (s: (s.kind or "") == "external") binary-caches);
        externalCaches = map (s: s.url) (lib.filter (s: s ? url) externals);
        externalKeys = lib.pipe externals [
          (lib.filter (s: (s.publicKey or "") != ""))
          (map (s: s.publicKey))
        ];
      in
      lib.mkIf (cfg.enable or false) {
        services.ncps = {
          enable = true;
          cache = {
            hostName = cfg.hostName or "ncps.local";
            dataPath = cfg.dataPath or "/var/cache/ncps";
            secretKeyPath = cfg.secretKeyPath or null;
          };
          server.addr = cfg.bind or "127.0.0.1:8501";
          upstream = {
            caches = (cfg.upstreamCaches or [ "https://cache.nixos.org" ]) ++ externalCaches;
            publicKeys =
              (cfg.upstreamPublicKeys or [
                "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
              ]
              )
              ++ externalKeys;
          };
        };

        networking.firewall.allowedTCPPorts = lib.optional (cfg.openFirewall or false) (cfg.port or 8501);
      };
  };
}
