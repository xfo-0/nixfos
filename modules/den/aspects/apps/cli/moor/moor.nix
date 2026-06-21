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
      { config, ... }:
      {
        imports = [ inputs.moor.homeModules.moor ];
        programs.moor = {
          enable = true;
          manifestFile = "${config.home.homeDirectory}/nx/moor.nuon";
        };
        xdg.configFile."moor/inputs.json".text = builtins.toJSON { repos = cloneEntries; };

        programs.nushell.extraConfig = ''
          def mfetch [group?: string] {
            let repos = (if ($group | is-empty) { moor ls } else { moor ls $group })
            $repos | where {|r| ($r.path | path exists) } | each {|r|
              let res = (if ($r.path | path join ".jj" | path exists) {
                ^jj -R $r.path git fetch
              } else {
                ^git -C $r.path fetch --all --quiet
              } | complete)
              { repo: $r.name, ok: ($res.exit_code == 0), err: ($res.stderr | str trim) }
            }
          }
        '';
      };
  };
}
