{ lib, config, ... }:
let
  hostFor = {
    github = "github.com";
    gitlab = "gitlab.com";
    sourcehut = "git.sr.ht";
  };
  refPrefixes = {
    "gh:" = "github.com";
    "github:" = "github.com";
    "gitlab:" = "gitlab.com";
    "sourcehut:" = "git.sr.ht";
  };
  normalize =
    u:
    let
      noQuery = builtins.head (lib.splitString "?" u);
      noProto = lib.last (lib.splitString "://" noQuery);
    in
    lib.removeSuffix ".git" noProto;
  shortPath =
    p:
    lib.concatStringsSep "/" (
      lib.take 2 (lib.splitString "/" (builtins.head (lib.splitString "?" p)))
    );
  refHost = u: lib.findFirst (pfx: lib.hasPrefix pfx u) null (lib.attrNames refPrefixes);
  toUrl =
    inp:
    let
      t = if (inp.type or null) == null then "github" else inp.type;
      typeHost = if (inp.host or "") != "" then inp.host else hostFor.${t} or null;
      pfx = refHost (inp.url or "");
    in
    if (inp.owner or "") != "" && (inp.repo or "") != "" && typeHost != null then
      "${typeHost}/${inp.owner}/${inp.repo}"
    else if pfx != null then
      "${refPrefixes.${pfx}}/" + shortPath (lib.removePrefix pfx inp.url)
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
