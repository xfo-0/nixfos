{ den, ... }:
{
  den.aspects.repos = {
    homeManager =
      { config, ... }:
      {
        xdg.configFile."nushell/repos.nu".source = ./repos.nu;
        programs.nushell.extraConfig = ''
          use ${config.xdg.configHome}/nushell/repos.nu *
        '';

        xdg.configFile."television/cable/repos.toml".text = ''
          [metadata]
          name = "repos"
          description = "cloned repo registry (repo scan cache)"

          [source]
          command = "nu -n -c 'use ${config.xdg.configHome}/nushell/repos.nu *; repo ls | get path | to text'"

          [preview]
          command = "jj -R {} --ignore-working-copy log -n 8 --no-graph 2>/dev/null || git -C {} log --oneline -8 2>/dev/null || ls -A1 {}"
        '';
      };
  };
}
