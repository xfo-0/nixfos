{ den, lib, ... }:
{
  den.aspects.nh = {
    includes = [
      den.aspects.nh.config
      den.aspects.nh.enable
    ];

    enable = {
      homeManager =
        { lib, inputs', ... }:
        {
          programs.nh = {
            enable = lib.mkDefault true;
            package = inputs'.nh.packages.default.overrideAttrs (_: {
              doCheck = false;
            });
            clean = {
              enable = lib.mkDefault true;
              extraArgs = lib.mkDefault "--keep-since 30d --keep 3";
            };
          };
        };
    };

    config = {
      homeManager =
        { config, lib, ... }:
        {
          programs.nh = {
            flake = lib.mkDefault "${config.home.homeDirectory}/nx";
            osFlake = lib.mkDefault "${config.home.homeDirectory}/nx";
            homeFlake = lib.mkDefault "${config.home.homeDirectory}/nx";
          };
        };
    };
  };
}
