{
  inputs,
  den,
  lib,
  ...
}:
{
  den.aspects.bat = {
    includes = [
      den.aspects.bat.aliases
      den.aspects.bat.enable
    ];

    enable = {
      homeManager =
        { pkgs, lib, ... }:
        {
          programs.bat = {
            enable = lib.mkDefault true;
            config.theme = lib.mkDefault "Monokai Extended";

            extraPackages = with pkgs.bat-extras; [
              batman
              batgrep
              batdiff
              batpipe
              batwatch
              prettybat
            ];
          };
        };

      persistUserIgnore =
        { hmConfig, ... }:
        {
          directories = [ "${hmConfig.xdg.cacheHome}/bat" ];
          files = [ "${hmConfig.xdg.stateHome}/lesshst" ];
        };
    };

    aliases = {
      homeManager = {
        home.shellAliases = inputs.self.lib.applyDefaults {
          cat = "bat";
          man = "batman";
          grep = "batgrep";
          diff = "batdiff";
          less = "batpipe";
          watch = "batwatch";
        };
      };
    };
  };
}
