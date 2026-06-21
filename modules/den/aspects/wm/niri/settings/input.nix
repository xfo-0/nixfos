{ ... }:
{
  den.aspects.niri.settings.input = {
    homeManager = {
      programs.niri.settings.input = {
        keyboard = {
          xkb.layout = "us";
          repeat-delay = 144;
          repeat-rate = 33;
          track-layout = "global";
        };
        # touchpad = {
        #   tap = false;
        #   natural-scroll = true;
        # };
        warp-mouse-to-focus.enable = true;
        focus-follows-mouse.enable = false;
      };
    };
  };
}
