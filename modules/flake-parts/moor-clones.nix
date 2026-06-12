{ lib, config, ... }:
let
  normalize =
    u:
    let
      noQuery = builtins.head (lib.splitString "?" u);
      noProto = lib.last (lib.splitString "://" noQuery);
    in
    lib.removeSuffix ".git" noProto;
  shortPath = p: lib.concatStringsSep "/" (lib.take 2 (lib.splitString "/" p));
  toUrl =
    inp:
    if (inp.owner or "") != "" && (inp.repo or "") != "" then
      "github.com/${inp.owner}/${inp.repo}"
    else if lib.hasPrefix "gh:" inp.url then
      "github.com/" + shortPath (lib.removePrefix "gh:" inp.url)
    else if lib.hasPrefix "github:" inp.url then
      "github.com/" + shortPath (lib.removePrefix "github:" inp.url)
    else
      normalize inp.url;
in
{
  options.flake-file.inputs = lib.mkOption {
    type = lib.types.lazyAttrsOf (
      lib.types.submoduleWith {
        shorthandOnlyDefinesConfig = true;
        modules = [
          {
            options.clone = {
              enable = lib.mkEnableOption "register a working clone of this input in the moor manifest";
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
    default = lib.mapAttrsToList (input: inp: {
      url = toUrl inp;
      inherit (inp.clone)
        tags
        aliases
        note
        private
        ;
      inherit input;
    }) (lib.filterAttrs (_: inp: inp.clone.enable) config.flake-file.inputs);
    defaultText = "moor manifest entries derived from flake-file.inputs.*.clone";
  };
}
