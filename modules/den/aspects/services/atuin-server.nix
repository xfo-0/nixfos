{ lib, ... }:
{
  den.aspects.services.atuin-server = {
    settings.options = {
      enable = lib.mkEnableOption "atuin shell-history sync server (tailnet)";
      port = lib.mkOption {
        type = lib.types.port;
        default = 8888;
        description = "Port the atuin sync server listens on (tailnet only).";
      };
      openRegistration = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Flip true ONLY to bootstrap the account, then back to false.";
      };
    };

    nixos =
      { host, ... }:
      let
        cfg = host.settings.services.atuin-server or { };
        port = cfg.port or 8888;
      in
      lib.mkIf (cfg.enable or false) {
        services.atuin = {
          enable = true;
          host = "0.0.0.0";
          inherit port;
          openRegistration = cfg.openRegistration or false;
          database.createLocally = true;
        };

        networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ port ];
      };

    persist =
      { host, ... }:
      let
        cfg = host.settings.services.atuin-server or { };
      in
      {
        directories = lib.optionals (cfg.enable or false) [
          {
            directory = "/var/lib/postgresql";
            user = "postgres";
            group = "postgres";
            mode = "0700";
          }
        ];
      };
  };
}
