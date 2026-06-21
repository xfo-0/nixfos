{
  den.aspects.kde-connect = {
    nixos =
      { pkgs, ... }:
      {
        programs.kdeconnect.enable = true;
        environment.systemPackages = [ pkgs.sshfs ];
      };

    persistUser =
      { hmConfig, ... }:
      {
        directories = [
          {
            directory = "${hmConfig.xdg.configHome}/kdeconnect";
            mode = "0700";
            how = "symlink";
            createLinkTarget = true;
          }
          {
            directory = "${hmConfig.xdg.dataHome}/kdeconnect";
            mode = "0700";
            how = "symlink";
            createLinkTarget = true;
          }
        ];
      };
  };
}
