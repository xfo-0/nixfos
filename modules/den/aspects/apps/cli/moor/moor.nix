{ den, config, ... }:
let
  cloneEntries = config.moor.clones;
in
{
  den.aspects.moor = {
    homeManager =
      { config, pkgs, ... }:
      {
        home.packages = [
          pkgs.fd
          pkgs.tokei
        ];
        xdg.configFile."nushell/moor.nu".source = ./moor.nu;
        xdg.configFile."moor/inputs.json".text = builtins.toJSON { repos = cloneEntries; };
        programs.nushell = {
          extraConfig = ''
            use ${config.xdg.configHome}/nushell/moor.nu *
          '';
          environmentVariables.MOOR_MANIFEST = "/etc/nixos/moor.nuon";
        };

        xdg.configFile."television/cable/moor.toml".text = ''
          [metadata]
          name = "moor"
          description = "cloned repo registry (moor scan cache)"

          [source]
          command = "nu -n -c 'use ${config.xdg.configHome}/nushell/moor.nu *; moor ls | get path | to text'"

          [preview]
          command = "jj -R {} --ignore-working-copy log -n 8 --no-graph 2>/dev/null || git -C {} log --oneline -8 2>/dev/null || ls -A1 {}"
        '';
      };
  };
}
