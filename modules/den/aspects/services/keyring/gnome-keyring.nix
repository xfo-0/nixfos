{ den, lib, ... }:
{
  den.aspects.keyring = {
    includes = [
      den.aspects.keyring.gnome-keyring
    ];

    gnome-keyring = {
      nixos =
        { config, lib, ... }:
        {
          services.gnome.gnome-keyring.enable = lib.mkDefault true;
          programs.seahorse.enable = lib.mkDefault true;

          xdg.portal.config.common = lib.mkIf config.services.gnome.gnome-keyring.enable {
            "org.freedesktop.impl.portal.Secret" = lib.mkDefault [ "gnome-keyring" ];
          };
        };

      persistUser =
        { hmConfig, ... }:
        {
          directories = [
            {
              directory = "${hmConfig.xdg.dataHome}/keyrings";
              how = "symlink";
              mode = "0700";
              createLinkTarget = true;
            }
            {
              directory = "${hmConfig.home.homeDirectory}/.gnupg";
              how = "symlink";
              mode = "0700";
              createLinkTarget = true;
            }
          ];
        };    };
  };
}
