{ den, lib, ... }:
{
  den.aspects.backup-sink = {
    settings.options.enable = lib.mkEnableOption "cross-host backup sink at /data/backup";

    nixos =
      { host, ... }:
      lib.mkIf (host.settings.backup-sink.enable or false) {
        systemd.tmpfiles.settings."backup-sink"."/data/backup".d = {
          user = "root";
          group = "root";
          mode = "0750";
        };
      };
  };
}
