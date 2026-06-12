{
  den,
  lib,
  routes,
  ...
}:
let
  mkCcRoute =
    { fromClass, intoSubPath }:
    routes.mkSystemRoute {
      inherit fromClass;
      path = [
        "environment"
        "etc"
        "coolercontrol/${intoSubPath}"
      ];
      adapterKey = "coolercontrol-route/${fromClass}";
      guardArgs.config = false;
      guard = { config, ... }: cfg: lib.mkIf config.programs.coolercontrol.enable cfg;
    };
in
{
  den.classes.coolercontrol-config.description = "CoolerControl config.toml (forwarded to environment.etc)";
  den.classes.coolercontrol-alerts.description = "CoolerControl alerts.json (forwarded to environment.etc)";
  den.classes.coolercontrol-ui.description = "CoolerControl UI config (forwarded to environment.etc)";

  den.policies.coolercontrol-config-route = mkCcRoute {
    fromClass = "coolercontrol-config";
    intoSubPath = "config.toml";
  };
  den.policies.coolercontrol-alerts-route = mkCcRoute {
    fromClass = "coolercontrol-alerts";
    intoSubPath = "alerts.json";
  };
  den.policies.coolercontrol-ui-route = mkCcRoute {
    fromClass = "coolercontrol-ui";
    intoSubPath = "config-ui.json";
  };

  den.default.includes = [
    den.policies.coolercontrol-config-route
    den.policies.coolercontrol-alerts-route
    den.policies.coolercontrol-ui-route
  ];

  den.aspects.coolercontrol = {
    nixos =
      {
        config,
        pkgs,
        lib,
        ...
      }:
      {
        programs.coolercontrol.enable = lib.mkDefault true;

        environment.systemPackages = with pkgs; [
          lm_sensors
          liquidctl
        ];

        environment.etc =
          lib.genAttrs
            [
              "coolercontrol/config.toml"
              "coolercontrol/alerts.json"
              "coolercontrol/config-ui.json"
            ]
            (file: {
              enable = lib.mkDefault (config.environment.etc.${file}.text != null);
              mode = lib.mkDefault "0644";
              text = lib.mkDefault null;
            });
      };

    persist.directories = [
      {
        directory = "/etc/coolercontrol";
        how = "symlink";
        createLinkTarget = true;
      }
    ];

    persistUserIgnore =
      { hmConfig, ... }:
      {
        directories = [
          "${hmConfig.xdg.dataHome}/org.coolercontrol.CoolerControl"
          "${hmConfig.xdg.cacheHome}/org.coolercontrol.CoolerControl"
          "${hmConfig.xdg.configHome}/org.coolercontrol.CoolerControl"
        ];
      };
  };
}
