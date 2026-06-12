{
  den.aspects.openscad = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.openscad ];
      };

    persistUser =
      { hmConfig, ... }:
      {
        directories = [
          {
            directory = "${hmConfig.xdg.configHome}/OpenSCAD";
            mode = "0700";
            how = "symlink";
            createLinkTarget = true;
          }
        ];
      };
  };
}
