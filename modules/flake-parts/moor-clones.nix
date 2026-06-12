{ lib, config, ... }:
let
  hostFor = {
    github = "github.com";
    gitlab = "gitlab.com";
    sourcehut = "git.sr.ht";
  };
  shorturls = config.flake-file.tack.shorturls or { };
  expand =
    u:
    let
      m = lib.findFirst (k: lib.hasPrefix "${k}:" u) null (lib.attrNames shorturls);
    in
    if m == null then
      u
    else
      lib.replaceStrings [ "{path}" ] [ (lib.removePrefix "${m}:" u) ] shorturls.${m};
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
  toUrl =
    inp:
    let
      t = if (inp.type or null) == null then "github" else inp.type;
      typeHost = if (inp.host or "") != "" then inp.host else hostFor.${t} or null;
      u = expand (inp.url or "");
      refType = lib.findFirst (ty: lib.hasPrefix "${ty}:" u) null (lib.attrNames hostFor);
    in
    if (inp.owner or "") != "" && (inp.repo or "") != "" && typeHost != null then
      "${typeHost}/${inp.owner}/${inp.repo}"
    else if refType != null then
      "${hostFor.${refType}}/" + shortPath (lib.removePrefix "${refType}:" u)
    else
      normalize u;
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
