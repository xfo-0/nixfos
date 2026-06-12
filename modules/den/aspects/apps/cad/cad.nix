{ den, ... }:
{
  den.aspects.cad.includes = with den.aspects; [
    freecad
    kicad
    openscad
    orca-slicer
  ];
}
