{ lib, ... }:
{
  den.aspects.services.media.servarr = {
    nixos =
      { host, ... }:
      let
        cfg = host.settings.services.media.base or { };
      in
      lib.mkIf (cfg.enable or false) {
        services.prowlarr = {
          enable = true;
          openFirewall = false;
        };
        services.sonarr = {
          enable = true;
          group = "media";
          openFirewall = false;
        };
        services.radarr = {
          enable = true;
          group = "media";
          openFirewall = false;
        };
        services.lidarr = {
          enable = true;
          group = "media";
          openFirewall = false;
        };
        services.bazarr = {
          enable = true;
          group = "media";
          openFirewall = false;
        };
        services.readarr = {
          enable = true;
          group = "media";
          openFirewall = false;
        };

        systemd.services.sonarr.serviceConfig.UMask = lib.mkForce "0002";
        systemd.services.radarr.serviceConfig.UMask = lib.mkForce "0002";
        systemd.services.lidarr.serviceConfig.UMask = lib.mkForce "0002";
        systemd.services.readarr.serviceConfig.UMask = lib.mkForce "0002";
        systemd.services.bazarr.serviceConfig.UMask = lib.mkForce "0002";
      };

    persistReplicated =
      { host, ... }:
      let
        cfg = host.settings.services.media.base or { };
      in
      {
        directories = lib.optionals (cfg.enable or false) [
          { directory = "/var/lib/prowlarr"; user = "prowlarr"; group = "prowlarr"; mode = "0700"; }
          { directory = "/var/lib/sonarr"; user = "sonarr"; group = "media"; mode = "0700"; }
          { directory = "/var/lib/radarr"; user = "radarr"; group = "media"; mode = "0700"; }
          { directory = "/var/lib/lidarr"; user = "lidarr"; group = "media"; mode = "0700"; }
          { directory = "/var/lib/readarr"; user = "readarr"; group = "media"; mode = "0700"; }
          { directory = "/var/lib/bazarr"; user = "bazarr"; group = "media"; mode = "0700"; }
        ];
      };
  };
}
