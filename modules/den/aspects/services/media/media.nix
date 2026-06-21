{ lib, ... }:
{
  den.aspects.services.media.base = {
    settings.options.enable = lib.mkEnableOption "media (arr) stack on this host";

    nixos =
      { host, pkgs, ... }:
      let
        cfg = host.settings.services.media.base or { };

        treeDirs = [
          "/data/media"
          "/data/media/tv"
          "/data/media/movies"
          "/data/media/music"
          "/data/media/books"
          "/data/torrents"
          "/data/torrents/tv"
          "/data/torrents/movies"
          "/data/torrents/music"
          "/data/torrents/books"
        ];

        dataServices = [
          "sonarr"
          "radarr"
          "lidarr"
          "readarr"
          "prowlarr"
          "bazarr"
          "qbittorrent"
          "unpackerr"
        ];
        netServices = [
          "pvpn"
          "natpmp-pvpn"
        ];

        gate = extra: {
          wantedBy = lib.mkForce [ "media.target" ];
          partOf = [ "media.target" ];
        }
        // extra;
      in
      lib.mkIf (cfg.enable or false) {
        users.groups.media = { };

        systemd.targets.media = {
          description = "On-demand media acquisition stack (arr + qBittorrent)";
        };

        systemd.services =
          (lib.genAttrs dataServices (_: gate { after = [ "media-tree.service" ]; }))
          // (lib.genAttrs netServices (_: gate { }))
          // {
            media-tree = {
              description = "Create /data media + torrents tree";
              wantedBy = [ "media.target" ];
              partOf = [ "media.target" ];
              unitConfig.RequiresMountsFor = "/data";
              path = [ pkgs.coreutils ];
              serviceConfig = {
                Type = "oneshot";
                RemainAfterExit = true;
                ExecStart = pkgs.writeShellScript "media-tree" (
                  lib.concatMapStringsSep "\n" (d: "install -d -o root -g media -m 2775 ${d}") treeDirs
                );
              };
            };
          };

        systemd.timers.configarr = {
          wantedBy = lib.mkForce [ "media.target" ];
          partOf = [ "media.target" ];
        };
      };
  };
}
