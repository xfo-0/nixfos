{
  den.aspects.python = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [
          pkgs.python3
          pkgs.uv
        ];
      };
  };
}
