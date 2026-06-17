{ lib, ... }:
{
  den.aspects.services.media.containers = {
    nixos =
      { host, ... }:
      let
        cfg = host.settings.services.media.base or { };
      in
      lib.mkIf (cfg.enable or false) {
        virtualisation.podman = {
          enable = true;
          autoPrune.enable = true;
        };
        virtualisation.oci-containers = {
          backend = "podman";
          containers = {
            jellyseerr = {
              image = "ghcr.io/fallenbagel/jellyseerr:2.5.2";
              ports = [ "127.0.0.1:5055:5055" ];
              volumes = [ "/var/lib/jellyseerr:/app/config" ];
              environment.TZ = "Etc/UTC";
            };
            configarr = {
              image = "ghcr.io/raydak-labs/configarr:1.14.0";
              volumes = [
                "/var/lib/configarr:/app/config"
                "/var/lib/configarr/repos:/app/repos"
              ];
              environment.TZ = "Etc/UTC";
            };
          };
        };
      };

    persist =
      { host, ... }:
      let
        cfg = host.settings.services.media.base or { };
      in
      {
        directories = lib.optionals (cfg.enable or false) [
          {
            directory = "/var/lib/containers";
            mode = "0700";
          }
        ];
      };

    persistReplicated =
      { host, ... }:
      let
        cfg = host.settings.services.media.base or { };
      in
      {
        directories = lib.optionals (cfg.enable or false) [
          {
            directory = "/var/lib/jellyseerr";
            mode = "0700";
          }
          {
            directory = "/var/lib/configarr";
            mode = "0700";
          }
        ];
      };
  };
}
