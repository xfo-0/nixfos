{
  den,
  config,
  inputs,
  ...
}:
let
  cloneEntries = config.moor.clones;
in
{
  den.aspects.moor = {
    homeManager =
      { ... }:
      {
        imports = [ inputs.moor.homeModules.moor ];
        programs.moor = {
          enable = true;
          manifestFile = "/etc/nixos/moor.nuon";
        };
        xdg.configFile."moor/inputs.json".text = builtins.toJSON { repos = cloneEntries; };
      };
  };
}
