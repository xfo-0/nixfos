{
  den.aspects.mpv = {
    homeManager = {
      programs.mpv = {
        enable = true;

        profiles = {
          hq = {
            profile = "high-quality";
            hwdec = "auto-safe";
          };
          fast = {
            profile = "fast";
          };
          stream = {
            cache = true;
            demuxer-max-bytes = "256MiB";
            demuxer-readahead-secs = 30;
            force-seekable = true;
          };
          image = {
            image-display-duration = "inf";
            loop-file = "inf";
          };
        };

        bindings = {
          "c" = "seek -5";
          "i" = "seek 5";
          "C" = "seek -60";
          "I" = "seek 60";
          "n" = "add volume 5";
          "e" = "add volume -5";
          "y" = "cycle fullscreen";
          "d" = "quit";
        };
      };
    };
  };
}
