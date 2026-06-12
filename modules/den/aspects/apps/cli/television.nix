{
  den.aspects.television = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.television ];
      };

    persistUser =
      { hmConfig, ... }:
      {
        directories = [
          {
            directory = "${hmConfig.xdg.configHome}/television";
            how = "symlink";
          }
        ];
      };
  };
}
