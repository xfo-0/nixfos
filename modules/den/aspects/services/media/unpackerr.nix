{ lib, ... }:
{
  den.aspects.services.media.unpackerr = {
    nixos =
      { host, pkgs, ... }:
      let
        cfg = host.settings.services.media.base or { };
      in
      lib.mkIf (cfg.enable or false) {
        users.users.unpackerr = {
          isSystemUser = true;
          group = "media";
        };
        systemd.services.unpackerr = {
          description = "Unpackerr — extract completed downloads for the arr apps";
          after = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            ExecStart = "${pkgs.unpackerr}/bin/unpackerr";
            User = "unpackerr";
            Group = "media";
            UMask = "0002";
            StateDirectory = "unpackerr";
            Restart = "always";
          };
        };
      };
  };
}
