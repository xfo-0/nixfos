{
  den.aspects.nodejs = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.nodejs ];
      };
  };
}
