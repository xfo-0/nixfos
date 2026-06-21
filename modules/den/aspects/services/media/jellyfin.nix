{ lib, ... }:
{
  den.aspects.services.media.jellyfin = {
    nixos =
      { host, ... }:
      let
        cfg = host.settings.services.media.base or { };
      in
      lib.mkIf (cfg.enable or false) {
        services.jellyfin = {
          enable = true;
          openFirewall = false;
          group = "media";
        };
        systemd.services.jellyfin.serviceConfig.UMask = lib.mkForce "0002";
      };

    persist =
      { host, ... }:
      let
        cfg = host.settings.services.media.base or { };
      in
      {
        directories = lib.optionals (cfg.enable or false) [
          { directory = "/var/lib/jellyfin"; user = "jellyfin"; group = "media"; mode = "0700"; }
        ];
      };
  };
}
