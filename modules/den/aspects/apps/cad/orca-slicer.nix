{
  den.aspects.orca-slicer = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.orca-slicer ];
      };

    persistUser =
      { hmConfig, ... }:
      {
        directories = [
          {
            directory = "${hmConfig.xdg.configHome}/OrcaSlicer";
            mode = "0700";
            how = "symlink";
            createLinkTarget = true;
          }
          {
            directory = "${hmConfig.xdg.dataHome}/orca-slicer";
            mode = "0700";
            how = "symlink";
            createLinkTarget = true;
          }
        ];
      };
  };
}
