{ inputs, ... }:
{
  flake-file.inputs.noctalia.url = "gh:noctalia-dev/noctalia-shell/e3d292656c340e5d766e11c3e4be922a39f7ac51";

  den.aspects.noctalia.core = {
    homeManager =
      { config, lib, ... }:
      let
        c = config.lib.stylix.colors.withHashtag;
      in
      {
        imports = [ inputs.noctalia.homeModules.default ];
        services.polkit-gnome.enable = lib.mkOverride 900 false;

        programs.noctalia = {
          enable = lib.mkDefault true;
          systemd.enable = true;

          customPalettes.kanso.dark = {
            mPrimary = c.base0D;
            mOnPrimary = c.base00;
            mSecondary = c.base0B;
            mOnSecondary = c.base00;
            mTertiary = c.base0E;
            mOnTertiary = c.base00;
            mError = c.base08;
            mOnError = c.base00;
            mHover = c.base0D;
            mOnHover = c.base00;
            mSurface = c.base00;
            mOnSurface = c.base05;
            mSurfaceVariant = "#1e1f20";
            mOnSurfaceVariant = "#a8aca8";
            mOutline = c.base03;
            mShadow = c.base00;
            terminal = {
              background = c.base00;
              foreground = c.base05;
              cursor = c.base05;
              cursorText = c.base00;
              selectionBg = c.base02;
              selectionFg = c.base05;
              normal = {
                black = c.base00;
                red = c.base08;
                green = c.base0B;
                yellow = c.base0A;
                blue = c.base0D;
                magenta = c.base0E;
                cyan = "#7aa89f";
                white = c.base05;
              };
              bright = {
                black = c.base03;
                red = "#e46876";
                green = "#87a987";
                yellow = "#e6c384";
                blue = "#7fb4ca";
                magenta = "#938aa9";
                cyan = c.base0C;
                white = c.base07;
              };
            };
          };

          settings = {
            shell = {
              polkit_agent = true;
              settings_show_advanced = true;
            };

            bar.main = {
              position = "top";
              thickness = 22;
              border = "outline";
              border_width = 1;
              margin_ends = 5;
              start = [ "active_window" ];
              center = [ "workspaces" ];
              end = [
                "media"
                "tray"
                "sysmon"
                "clock"
                "volume"
                "notifications"
              ];
            };

            theme = {
              mode = "auto";
              source = "custom";
              custom_palette = "kanso";
              templates = {
                enable_builtin_templates = false;
                enable_community_templates = false;
              };
            };

            wallpaper.enabled = false;

            weather = {
              enabled = true;
              unit = "celsius";
            };

            location.address = "Fresno";
          };
        };
      };

    persistUser =
      { hmConfig, ... }:
      {
        directories = [
          "${hmConfig.xdg.cacheHome}/noctalia"
          {
            directory = "${hmConfig.xdg.cacheHome}/cliphist";
            mode = "0700";
            how = "symlink";
            createLinkTarget = true;
          }
          {
            directory = "${hmConfig.xdg.stateHome}/noctalia";
            how = "symlink";
            createLinkTarget = true;
          }
        ];
      };

    persistUserTmp =
      { hmConfig, ... }:
      {
        "${hmConfig.xdg.cacheHome}" = { };
        "${hmConfig.xdg.configHome}" = { };
        "${hmConfig.xdg.configHome}/noctalia" = { };
        "${hmConfig.xdg.stateHome}" = { };
      };
  };
}
