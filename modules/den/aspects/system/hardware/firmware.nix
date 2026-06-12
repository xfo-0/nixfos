{ den, ... }:
{
  den.aspects.firmware = {
    nixos =
      { config, lib, ... }:
      let
        gated =
          config.hardware.facter.enable
          && (config.hardware.facter.detected.virtualisation.none.enable or false);
      in
      lib.mkIf gated {
        services.fwupd.enable = lib.mkDefault true;
        hardware.enableAllFirmware = lib.mkDefault true;
        # fwupd-refresh.service runs as DynamicUser; polkit denies its
        # non-interactive refresh-remote call ("Failed to obtain auth")
        security.polkit.extraConfig = ''
          polkit.addRule(function(action, subject) {
            if (action.id == "org.freedesktop.fwupd.refresh-remote" && subject.user == "fwupd-refresh") {
              return polkit.Result.YES;
            }
          });
        '';
      };

    persist.directories = [
      {
        directory = "/var/lib/fwupd";
        user = "fwupd-refresh";
        group = "fwupd-refresh";
      }
    ];
  };

  den.schema.host.includes = [ den.aspects.firmware ];
}
