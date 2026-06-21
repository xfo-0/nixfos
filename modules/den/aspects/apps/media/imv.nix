{
  den.aspects.imv = {
    homeManager =
      { lib, ... }:
      {
        programs.imv.enable = true;

        xdg.mimeApps.defaultApplications =
          let
            application = "imv.desktop";
            mimeTypes = [
              "image/png"
              "image/jpeg"
              "image/gif"
              "image/webp"
              "image/bmp"
              "image/tiff"
              "image/svg+xml"
              "image/heif"
              "image/avif"
              "image/jxl"
            ];
          in
          lib.genAttrs mimeTypes (_: application);
      };
  };
}
