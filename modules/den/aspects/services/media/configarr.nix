{ lib, ... }:
{
  den.aspects.services.media.configarr = {
    nixos =
      { host, config, pkgs, ... }:
      let
        cfg = host.settings.services.media.base or { };

        configYml = pkgs.writeText "configarr-config.yml" ''
          trashGuideUrl: https://github.com/TRaSH-Guides/Guides
          recyclarrConfigUrl: https://github.com/recyclarr/config-templates

          sonarr:
            series:
              base_url: http://localhost:8989
              api_key: !env SONARR__AUTH__APIKEY
              include:
                - template: sonarr-quality-definition-series
                - template: sonarr-v4-quality-profile-web-1080p
                - template: sonarr-v4-custom-formats-web-1080p

          radarr:
            movies:
              base_url: http://localhost:7878
              api_key: !env RADARR__AUTH__APIKEY
              include:
                - template: radarr-quality-definition-movie
                - template: radarr-quality-profile-remux-web-1080p
                - template: radarr-custom-formats-remux-web-1080p
        '';

        image = "ghcr.io/raydak-labs/configarr:1.28.0";
        envFile = config.sops.secrets."media-arr.env".path;
      in
      lib.mkIf (cfg.enable or false) {
        systemd.tmpfiles.settings."configarr-state" = {
          "/var/lib/configarr".d = {
            mode = "0700";
          };
          "/var/lib/configarr/repos".d = {
            mode = "0700";
          };
        };

        systemd.services.configarr = {
          description = "Configarr — sync TRaSH custom formats + quality profiles to *arr";
          after = [
            "network-online.target"
            "sonarr.service"
            "radarr.service"
          ];
          wants = [ "network-online.target" ];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = lib.concatStringsSep " " [
              "${pkgs.podman}/bin/podman run --rm --network=host"
              "--env-file ${envFile}"
              "-v ${configYml}:/app/config/config.yml:ro"
              "-v /var/lib/configarr/repos:/app/repos"
              image
            ];
          };
        };

        systemd.timers.configarr = {
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnCalendar = "daily";
            Persistent = true;
            RandomizedDelaySec = "15m";
          };
        };
      };

    persistReplicated =
      { host, ... }:
      let
        cfg = host.settings.services.media.base or { };
      in
      {
        directories = lib.optionals (cfg.enable or false) [
          {
            directory = "/var/lib/configarr";
            mode = "0700";
          }
        ];
      };
  };
}
