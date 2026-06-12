{
  den.aspects.rbw = {
    homeManager =
      { config, pkgs, ... }:
      {
        programs.rbw.enable = true;

        sops.secrets."rbw/email" = { };
        sops.secrets."rbw/base-url" = { };
        sops.templates."rbw-config.json".content = builtins.toJSON {
          email = config.sops.placeholder."rbw/email";
          base_url = config.sops.placeholder."rbw/base-url";
          pinentry = "${pkgs.pinentry-qt}/bin/pinentry-qt";
        };

        xdg.configFile."rbw/config.json".source =
          config.lib.file.mkOutOfStoreSymlink
            config.sops.templates."rbw-config.json".path;
      };
  };
}
