{
  lib,
  ...
}:
{
  den.aspects.niri.settings.main = {
    homeManager =
      { config, ... }:
      let
        colors = config.lib.stylix.colors.withHashtag;
      in
      {
        programs.niri = {
          settings = {
            prefer-no-csd = true;
            hotkey-overlay.skip-at-startup = true;

            cursor = {
              theme = "phinger-cursors-dark";
              size = 20;
              hide-after-inactive-ms = 1000;
            };

            layout = {
              gaps = 5;
              struts = {
                left = 0;
                right = 0;
                top = 0;
                bottom = 0;
              };
              center-focused-column = "never";
              empty-workspace-above-first = true;
              background-color = colors.base00;

              default-column-width.proportion = 1.0;

              preset-column-widths = [
                { proportion = 1.0 / 3.0; }
                { proportion = 1.0 / 2.0; }
                { proportion = 2.0 / 3.0; }
                { proportion = 1.0; }
              ];

              focus-ring = {
                enable = true;
                width = 1;
                active.color = "${colors.base03}50";
                inactive.color = "${colors.base00}00";
              };

              border = {
                enable = true;
                width = 1;
                active.color = colors.base04;
                inactive.color = colors.base00;
              };

              tab-indicator = {
                hide-when-single-tab = true;
                place-within-column = true;
                gap = 5.0;
                width = 4.0;
                length.total-proportion = 0.5;
                position = "left";
                gaps-between-tabs = 2;
                corner-radius = 0.0;
              };
            };

            overview.backdrop-color = "#0d0d0d";
            clipboard.disable-primary = true;
            animations.slowdown = 0.28;
            screenshot-path = "${config.xdg.userDirs.pictures}/Screenshots/%Y-%m-%d %H-%M-%S.png";
          };
          extraConfig = lib.replaceStrings [ "// syntax: rust\n" ] [ "" ] ''
            // syntax: rust
            output "DP-1" {
              backdrop-color "${colors.base00}"
              transform "normal"
              variable-refresh-rate on-demand=true
            }
            output "DP-2" {
              backdrop-color "${colors.base00}"
              transform "normal"
              variable-refresh-rate on-demand=true
            }
            output "HDMI-A-1" {
              backdrop-color "${colors.base00}"
              transform "normal"
              variable-refresh-rate on-demand=true
            }
            output "HDMI-A-2" {
              backdrop-color "${colors.base00}"
              transform "normal"
              variable-refresh-rate on-demand=true
            }
            output "HDMI-A-5" {
              backdrop-color "${colors.base00}"
              transform "normal"
              variable-refresh-rate on-demand=true
            }
            output "eDP-1" {
              backdrop-color "${colors.base00}"
              transform "normal"
              variable-refresh-rate on-demand=true
            }
          '';
        };
      };
  };

}
