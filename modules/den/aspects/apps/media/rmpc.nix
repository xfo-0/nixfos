{
  den.aspects.rmpc = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.rmpc ];
      };

    persistUser =
      { hmConfig, ... }:
      {
        directories = [
          {
            directory = "${hmConfig.xdg.configHome}/rmpc";
            how = "symlink";
          }
        ];
      };
  };
}
