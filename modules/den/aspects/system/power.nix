{ den, ... }:
{
  den.aspects.power.nixos =
    { config, lib, ... }:
    let
      isBaremetal = config.hardware.facter.detected.virtualisation.none.enable or false;
      gated = config.hardware.facter.enable && isBaremetal;
    in
    lib.mkMerge [
      (lib.mkIf gated {
        powerManagement.cpuFreqGovernor = lib.mkDefault "schedutil";
      })
      (lib.mkIf (gated && config.hardware.cpu.amd.updateMicrocode) {
        systemd.tmpfiles.rules = [
          "w /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference - - - - balance_performance"
        ];
      })
    ];

  den.schema.host.includes = [ den.aspects.power ];
}
