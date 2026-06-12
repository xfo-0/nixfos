{ den, ... }:
{
  den.aspects.desktop-type = {
    _.desktop-environment = { };

    _.window-manager = {
      _.niri = {
        includes = [
          {
            nixos =
              { lib, ... }:
              {
                services.displayManager.defaultSession = lib.mkDefault "niri";
              };
          }

          den.aspects.niri
        ];
      };
    };
  };
}
