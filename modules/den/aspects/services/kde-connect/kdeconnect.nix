{
  den.aspects.kde-connect = {
    nixos =
      { pkgs, lib, ... }:
      {
        programs.kdeconnect = {
          enable = lib.mkDefault true;
          package = lib.mkDefault pkgs.kdePackages.kdeconnect-kde;
        };
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
    _.to-users = {
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
  };
}
