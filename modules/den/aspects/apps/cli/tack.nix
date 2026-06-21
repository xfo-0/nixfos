{ inputs, ... }:
{
  den.aspects.tack.homeManager =
    { pkgs, ... }:
    let
      tackPkgs = inputs.tack.packages.${pkgs.stdenv.hostPlatform.system};
    in
    {
      home.packages = [ (tackPkgs.tack or tackPkgs.default) ];
    };
}
