{
  den.aspects.xdg-termfilechooser = {
    homeManager =
      { pkgs, lib, ... }:
      let
        term-filechooser = pkgs.writeShellApplication {
          name = "term-filechooser";
          runtimeInputs = [ pkgs.foot ];
          text = ''
            if ! systemctl --user is-active -q foot.service; then
              systemctl --user start foot.service || true
              sock="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/foot-''${WAYLAND_DISPLAY:-wayland-1}.sock"
              for _ in $(seq 1 40); do
                [ -S "$sock" ] && break
                sleep 0.05
              done
            fi
            exec footclient --app-id=term_filechooser "$@"
          '';
        };
      in
      {
        xdg.portal = {
          extraPortals = lib.mkDefault [ pkgs.xdg-desktop-portal-termfilechooser ];
          config.niri."org.freedesktop.impl.portal.FileChooser" = [ "termfilechooser" ];
        };

        xdg.configFile."xdg-desktop-portal-termfilechooser/config".text = ''
          [filechooser]
          cmd=${pkgs.xdg-desktop-portal-termfilechooser}/share/xdg-desktop-portal-termfilechooser/yazi-wrapper.sh
          default_dir=$HOME
          env=TERMCMD='${term-filechooser}/bin/term-filechooser'
          env=PATH="$PATH:/run/current-system/sw/bin"
        '';
      };

    niri = {
      settings.window-rules = [
        {
          matches = [ { app-id = "^term_filechooser$"; } ];
          open-floating = true;
          default-column-width.proportion = 0.4;
          default-window-height.proportion = 0.5;
        }
      ];
    };
  };
}
