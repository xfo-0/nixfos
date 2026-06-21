{
  den.aspects.direnv = {
    homeManager =
      { lib, ... }:
      {
        programs.direnv = {
          enable = lib.mkDefault true;
          nix-direnv.enable = lib.mkDefault true;
        };
      };
    persistUser =
      { hmConfig, ... }:
      {
        directories = [
          {
            directory = "${hmConfig.xdg.dataHome}/direnv/allow";
            how = "symlink";
            createLinkTarget = true;
          }
        ];
      };
    persistUserTmp =
      { hmConfig, ... }:
      {
        ".local" = { };
        "${hmConfig.xdg.dataHome}" = { };
        "${hmConfig.xdg.dataHome}/direnv" = { };
      };
  };
}
