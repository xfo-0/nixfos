{ ... }:
{
  den.aspects.npins.homeManager =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.npins ];
    };
}
