{
  den.aspects.python = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.uv ];
      };
  };
}
