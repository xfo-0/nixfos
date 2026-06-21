{
  den.aspects.zathura = {
    homeManager =
      { lib, ... }:
      {
        programs.zathura = {
          enable = lib.mkDefault true;
        };

        xdg.mimeApps.defaultApplications =
          let
            application = "org.pwmt.zathura.desktop";
            mimeTypes = [
              "application/pdf"
              "application/epub+zip"
            ];
          in
          lib.genAttrs mimeTypes (_: application);
      };

    persistUser =
      { hmConfig, ... }:
      {
        directories = [
          {
            directory = "${hmConfig.xdg.configHome}/zathura";
            how = "symlink";
          }
        ];
      };

    persistUserIgnore =
      { hmConfig, ... }:
      {
        directories = [ "${hmConfig.xdg.dataHome}/zathura" ];
      };
  };
}
