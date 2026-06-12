{ lib, config, ... }:
{
  options.flake-file.inputs = lib.mkOption {
    type = lib.types.lazyAttrsOf (
      lib.types.submoduleWith {
        shorthandOnlyDefinesConfig = true;
        modules = [
          {
            options.clone = {
              enable = lib.mkEnableOption "register a working clone of this input in the repos manifest";
              tags = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [ ];
              };
              aliases = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [ ];
              };
              note = lib.mkOption {
                type = lib.types.str;
                default = "";
              };
              private = lib.mkOption {
                type = lib.types.bool;
                default = false;
              };
            };
          }
        ];
      }
    );
  };

  options.moor.clones = lib.mkOption {
    type = lib.types.listOf lib.types.raw;
    readOnly = true;
    default = lib.mapAttrsToList (
      input: inp:
      {
        inherit input;
      }
      // builtins.removeAttrs inp.clone [ "enable" ]
    ) (lib.filterAttrs (_: inp: inp.clone.enable) config.flake-file.inputs);
    defaultText = "clone-enabled flake-file inputs; urls resolve from the pin lock at scan time";
  };
}
