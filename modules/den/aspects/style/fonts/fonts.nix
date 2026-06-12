{
  den.aspects.fonts = {
    nixos =
      { pkgs, ... }:
      {
        fonts = {
          enableDefaultPackages = true;
          fontDir.enable = true;
          packages = with pkgs; [
            ioskeley-mono.normal-term-NF
            noto-fonts
            noto-fonts-cjk-sans
            noto-fonts-cjk-serif
            noto-fonts-color-emoji
          ];

          fontconfig = {
            enable = true;
            useEmbeddedBitmaps = true;
            localConf = ''
              <?xml version="1.0"?>
              <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
              <fontconfig>
                <!-- Add Symbols Nerd Font as a global fallback -->
                <match target="pattern">
                  <test name="family" compare="not_eq">
                    <string>Symbols Nerd Font</string>
                  </test>
                  <edit name="family" mode="append">
                    <string>Symbols Nerd Font</string>
                  </edit>
                </match>
              </fontconfig>
            '';
            defaultFonts = {
              monospace = [ "IoskeleyMonoTerm Nerd Font" ];
              sansSerif = [ "IoskeleyMonoTerm Nerd Font" ];
              serif = [ "IoskeleyMonoTerm Nerd Font" ];
            };
          };
        };
      };

    homeManager = {
      fonts.fontconfig.enable = true;
    };

    persistUserIgnore =
      { hmConfig, ... }:
      {
        directories = [ "${hmConfig.xdg.cacheHome}/fontconfig" ];
      };
  };
}
