{ inputs, ... }:
{
  imports = [ inputs.moor.flakeModules.clone-inputs ];
}
