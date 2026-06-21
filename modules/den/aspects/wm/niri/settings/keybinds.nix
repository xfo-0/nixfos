{
  den.aspects.niri.settings.keybinds = {
    homeManager =
      { config, ... }:
      {
        programs.niri.settings.binds =
          with config.lib.niri.actions;
          let
            sh = spawn "sh" "-c";
            shotDir = "${config.xdg.userDirs.pictures}/Screenshots";
            satty =
              grab:
              ''mkdir -p "${shotDir}" && ${grab} | satty --filename - --output-filename "${shotDir}/$(date '+%Y-%m-%d %H-%M-%S').png" --early-exit --copy-command wl-copy'';
          in
          {
            # Workspace focus (offset by 1 for empty-workspace-above-first)
            "Mod+1".action = focus-workspace 2;
            "Mod+2".action = focus-workspace 3;
            "Mod+3".action = focus-workspace 4;
            "Mod+4".action = focus-workspace 5;
            "Mod+5".action = focus-workspace 6;
            "Mod+6".action = focus-workspace 7;
            "Mod+7".action = focus-workspace 8;
            "Mod+8".action = focus-workspace 9;
            "Mod+9".action = focus-workspace 10;

            # Workspace move
            "Mod+Ctrl+1".action.move-window-to-workspace = 2;
            "Mod+Ctrl+2".action.move-window-to-workspace = 3;
            "Mod+Ctrl+3".action.move-window-to-workspace = 4;
            "Mod+Ctrl+4".action.move-window-to-workspace = 5;
            "Mod+Ctrl+5".action.move-window-to-workspace = 6;
            "Mod+Ctrl+6".action.move-window-to-workspace = 7;
            "Mod+Ctrl+7".action.move-window-to-workspace = 8;
            "Mod+Ctrl+8".action.move-window-to-workspace = 9;
            "Mod+Ctrl+9".action.move-window-to-workspace = 10;

            # Navigation
            "Mod+C".action = focus-column-left;
            "Mod+I".action = focus-column-right;
            "Mod+E".action = focus-window-or-workspace-down;
            "Mod+N".action = focus-window-or-workspace-up;
            "Mod+Home".action = focus-column-first;
            "Mod+End".action = focus-column-last;

            # Move windows
            "Mod+Shift+C".action = consume-or-expel-window-left;
            "Mod+Shift+I".action = consume-or-expel-window-right;
            "Mod+Shift+E".action = move-window-down-or-to-workspace-down;
            "Mod+Shift+N".action = move-window-up-or-to-workspace-up;

            # Window actions
            "Mod+D".action = close-window;
            "Mod+A".action = toggle-column-tabbed-display;
            "Mod+X".action = switch-preset-column-width;
            "Mod+Y".action = maximize-column;
            "Mod+Equal".action = center-column;
            "Mod+H".action = expand-column-to-available-width;
            "Mod+O".action = toggle-window-floating;
            "Mod+L".action = switch-focus-between-floating-and-tiling;
            "Mod+Shift+4".action = fullscreen-window;

            # Applications
            "Mod+Slash" = {
              action = spawn "desktop-launch";
              repeat = false;
            };
            "Mod+T" = {
              action = spawn "niri-focus";
              repeat = false;
            };
            "Mod+V" = {
              action = sh "cliphist list | term-pick | cliphist decode 2>/dev/null | wl-copy";
              repeat = false;
            };
            "Mod+P" = {
              action = spawn "rbw-pick" "pass";
              repeat = false;
            };
            "Mod+Shift+P" = {
              action = spawn "rbw-pick" "code";
              repeat = false;
            };
            "Mod+Shift+y" = {
              action = sh (satty ''grim -g "$(slurp -d)" -'');
              repeat = false;
            };

            # System
            "Mod+Q".action = spawn "brightness-ctl-osd" "up";
            "Mod+J".action = spawn "brightness-ctl-osd" "down";
            "Mod+Shift+Q".action =
              sh ''current=$(busctl --user get-property rs.wl-gammarelay / rs.wl.gammarelay Temperature | awk '{print $2}'); if [ "$current" -lt 5000 ]; then busctl --user set-property rs.wl-gammarelay / rs.wl.gammarelay Temperature q 6500; else busctl --user set-property rs.wl-gammarelay / rs.wl.gammarelay Temperature q 3500; fi'';
          };
      };
  };
}
