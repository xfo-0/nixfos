{ lib, ... }:
{
  den.aspects.services.binary-cache.harmonia = {
    settings = {
      options.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable harmonia cache service on this host.";
      };
      options.bind = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1:5000";
        description = "Address harmonia binds to.";
      };
      options.port = lib.mkOption {
        type = lib.types.port;
        default = 5000;
        description = "Port reported in emitted substituter URL (must match bind).";
      };
      options.publicKey = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Public key for signed paths. Empty = peers do not trust this cache.";
      };
      options.signKeyPaths = lib.mkOption {
        type = lib.types.listOf lib.types.path;
        default = [ ];
      };
      options.workers = lib.mkOption {
        type = lib.types.int;
        default = 4;
      };
      options.openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };

    binary-caches =
      { host, ... }:
      let
        cfg = host.settings.services.binary-cache.harmonia or { };
      in
      lib.optionalAttrs ((cfg.enable or false) && host.ip != null) {
        url = "http://${host.ip}:${toString (cfg.port or 5000)}";
        publicKey = cfg.publicKey or "";
        kind = "harmonia";
      };

    nixos =
      { host, ... }:
      let
        cfg = host.settings.services.binary-cache.harmonia or { };
      in
      lib.mkIf (cfg.enable or false) {
        services.harmonia.cache = {
          enable = true;
          signKeyPaths = cfg.signKeyPaths or [ ];
          settings = {
            bind = cfg.bind or "127.0.0.1:5000";
            workers = cfg.workers or 4;
          };
        };

        networking.firewall.interfaces.tailscale0.allowedTCPPorts = lib.optional (cfg.openFirewall or false
        ) (cfg.port or 5000);
      };
  };

  den.aspects.services.binary-cache.harmonia-client = {
    nixos =
      {
        host,
        binary-caches,
        lib,
        ...
      }:
      let
        selfPort = host.settings.services.binary-cache.harmonia.port or 5000;
        selfUrl = if host.ip == null then null else "http://${host.ip}:${toString selfPort}";
        peers = lib.filter (s: (s.kind or "") == "harmonia" && s ? url && s.url != selfUrl) binary-caches;
        signedPeers = lib.filter (s: s.publicKey != "") peers;
      in
      {
        nix.settings.trusted-public-keys = lib.mkAfter (map (s: s.publicKey) signedPeers);
      };
  };
}
