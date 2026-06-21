{ lib, ... }:
{
  den.aspects.services.media.hd-idle = {
    settings.options.spinDownDisks = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "by-id disk names (under /dev/disk/by-id) to spin down after ~30min idle via hd-idle (e.g. the media HDD). Empty = off. Runs in base so the disk sleeps after playback/media.target idle.";
    };

    nixos =
      { host, pkgs, ... }:
      let
        cfg = host.settings.services.media.base or { };
        disks = host.settings.services.media.hd-idle.spinDownDisks or [ ];
        diskArgs = lib.concatMapStringsSep " " (d: "-a ${d} -i 1800") disks;
      in
      lib.mkIf ((cfg.enable or false) && (disks != [ ])) {
        systemd.services.hd-idle = {
          description = "Spin down idle media HDD(s) after long idle";
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            Type = "simple";
            ExecStart = "${pkgs.hd-idle}/bin/hd-idle -i 0 ${diskArgs}";
            Restart = "always";
            RestartSec = "10";
          };
        };
      };
  };
}
