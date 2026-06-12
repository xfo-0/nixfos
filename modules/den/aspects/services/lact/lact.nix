{
  den,
  lib,
  routes,
  ...
}:
{
  den.classes.lact.description = "Lact config.yaml (forwarded to environment.etc)";

  den.aspects.lact = {
    includes = [
      den.aspects.lact.class
      den.aspects.lact.enable
    ];

    enable = {
      nixos =
        { lib, ... }:
        {
          services.lact.enable = lib.mkDefault true;
        };

      persist =
        { config, lib, ... }:
        {
          directories = lib.mkIf (!config.environment.etc."lact/config.yaml".enable) [
            {
              directory = "/etc/lact";
              how = "symlink";
              createLinkTarget = true;
            }
          ];
        };

      persistIgnore =
        { config, lib, ... }:
        {
          directories = lib.mkIf config.environment.etc."lact/config.yaml".enable [
            "/etc/lact"
          ];
        };

      persistUser =
        { hmConfig, ... }:
        {
          directories = [
            {
              directory = "${hmConfig.xdg.configHome}/lact";
              how = "symlink";
              createLinkTarget = true;
            }
          ];
        };
    };

    class = {
      includes = [ den.aspects.lact.class.setup ];

      setup = {
        nixos =
          { config, lib, ... }:
          {
            environment.etc."lact/config.yaml" = {
              enable = lib.mkDefault (config.environment.etc."lact/config.yaml".text != null);
              mode = lib.mkDefault "0644";
              text = lib.mkDefault null;
            };
          };
      };
    };
  };

  den.policies.lact-route = routes.mkSystemRoute {
    fromClass = "lact";
    path = [
      "environment"
      "etc"
      "lact/config.yaml"
    ];
    adapterKey = "lact-route";
    guardArgs.config = false;
    guard = { config, ... }: cfg: lib.mkIf config.services.lact.enable cfg;
  };

  den.default.includes = [ den.policies.lact-route ];
}
