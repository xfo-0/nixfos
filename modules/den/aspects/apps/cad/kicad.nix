{
  den.aspects.kicad = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.kicad ];
      };

    persistUser =
      { hmConfig, ... }:
      {
        directories = [
          {
            directory = "${hmConfig.xdg.configHome}/kicad";
            mode = "0700";
            how = "symlink";
            createLinkTarget = true;
          }
          {
            directory = "${hmConfig.xdg.dataHome}/kicad";
            mode = "0700";
            how = "symlink";
            createLinkTarget = true;
          }
        ];
      };
  };
}
