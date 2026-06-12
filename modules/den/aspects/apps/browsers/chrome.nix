{
  den.aspects.browser.chrome = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [ chromium ];
      };

    persistUser =
      { hmConfig, ... }:
      {
        directories = [
          {
            directory = "${hmConfig.xdg.configHome}/google-chrome";
            how = "symlink";
            mode = "0700";
            createLinkTarget = true;
          }
        ];
      };

    persistUserIgnore =
      { hmConfig, ... }:
      {
        directories = [ "${hmConfig.xdg.cacheHome}/google-chrome" ];
      };
  };
}
