{ lib, ... }:
{
  den.aspects.services.home-assistant = {
    settings = {
      options.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable home-assistant service on this host.";
      };
      options.openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
      options.listenPort = lib.mkOption {
        type = lib.types.port;
        default = 8123;
      };
      options.trustedNetworks = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "192.168.12.0/24" ];
        description = "Networks allowed direct access (no auth proxy).";
      };
      options.extraComponents = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "default_config"
          "esphome"
          "met"
          "radio_browser"
        ];
        description = "Component names passed to services.home-assistant.extraComponents.";
      };
      options.config = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = { };
        description = "Extra config merged into services.home-assistant.config (cascade-driven).";
      };
    };

    nixos =
      { host, ... }:
      let
        cfg = host.settings.services.home-assistant;
        baseConfig = {
          homeassistant = {
            name = "Home";
            unit_system = "us_customary";
            time_zone = host.settings.core.timezone or "UTC";
            country = "US";
          };
          http = {
            server_port = cfg.listenPort;
            use_x_forwarded_for = true;
            trusted_proxies = cfg.trustedNetworks;
          };
          default_config = { };
        };
      in
      lib.mkIf cfg.enable {
        services.home-assistant = {
          enable = true;
          openFirewall = cfg.openFirewall;
          extraComponents = cfg.extraComponents;
          config = lib.recursiveUpdate baseConfig cfg.config;
        };
      };
  };
}
