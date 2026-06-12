{
  den.aspects.xdg-termfilechooser = {
    homeManager =
      { pkgs, lib, ... }:
      {
        xdg.portal = {
          extraPortals = lib.mkDefault [ pkgs.xdg-desktop-portal-termfilechooser ];
          config.niri."org.freedesktop.impl.portal.FileChooser" = [ "termfilechooser" ];
        };

        xdg.configFile."xdg-desktop-portal-termfilechooser/config".text = ''
          [filechooser]
          cmd=${pkgs.xdg-desktop-portal-termfilechooser}/share/xdg-desktop-portal-termfilechooser/yazi-wrapper.sh
          default_dir=$HOME
          env=TERMCMD='${pkgs.foot}/bin/footclient --app-id=term_filechooser'
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
