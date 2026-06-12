{
  den.aspects.niri.rules.general = {
    homeManager = {
      programs.niri.settings = {
        window-rules = [
          {
            matches = [
              { app-id = "term_float"; }
              { app-id = "it.catboy.ripdrag"; }
            ];
            open-floating = true;
            border = {
              enable = true;
              width = 2;
            };
            shadow.enable = true;
          }
          {
            matches = [ { app-id = "term_picker"; } ];
            open-floating = true;
            min-width = 1200;
            max-width = 1200;
            min-height = 600;
            max-height = 600;
            border = {
              enable = true;
              width = 2;
            };
            shadow.enable = true;
          }
          {
            matches = [ { app-id = "it.catboy.ripdrag"; } ];
            border.active.color = "#75797f50";
            focus-ring.active.color = "#5C606650";
          }
          {
            matches = [
              {
                app-id = "mpv";
                title = "^yazi: ";
              }
            ];
            open-floating = true;
            border = {
              enable = true;
              width = 2;
            };
            shadow.enable = true;
          }
        ];

        layer-rules = [
          {
            matches = [ { namespace = "overview"; } ];
            place-within-backdrop = true;
          }
        ];
      };
    };
  };
}
