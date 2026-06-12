{
  den.aspects.tridactyl = {
    homeManager =
      { pkgs, config, ... }:
      let
        c = config.lib.stylix.colors.withHashtag;
        kansoRoot = ''
          :root {
            --bg: ${c.base00};
            --bg1: ${c.base01};
            --currentline: ${c.base02};
            --comment: ${c.base03};
            --fg-dim: ${c.base04};
            --fg: ${c.base05};
            --fg-bright: ${c.base06};
            --fg-light: ${c.base07};
            --red: ${c.base08};
            --orange: ${c.base09};
            --yellow: ${c.base0A};
            --green: ${c.base0B};
            --cyan: ${c.base0C};
            --blue: ${c.base0D};
            --purple: ${c.base0E};
            --pink: ${c.base0F};
          }
        '';
      in
      {
        home.packages = [ pkgs.tridactyl-native ];

        xdg.configFile = {
          "tridactyl/tridactylrc".source = ./tridactyl-config/tridactylrc;
          "tridactyl/themes/kanso.css".text =
            kansoRoot + builtins.readFile ./tridactyl-config/themes/kanso.css;
          "tridactyl/scripts/tab-multi.js".source = ./tridactyl-config/scripts/tab-multi.js;
        };
      };
  };
}
