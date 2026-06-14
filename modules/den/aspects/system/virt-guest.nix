{ den, ... }:
{
  den.aspects.virt-guest.nixos =
    { config, lib, ... }:
    let
      gated = config.hardware.facter.enable;
      v = config.hardware.facter.detected.virtualisation;
    in
    lib.mkMerge [
      (lib.mkIf (gated && (v.qemu.enable or false)) {
        services.qemuGuest.enable = lib.mkDefault true;
      })
      (lib.mkIf (gated && (v.hyperv.enable or false)) {
        virtualisation.hypervGuest.enable = lib.mkDefault true;
      })
      (lib.mkIf (gated && (v.oracle.enable or false)) {
        virtualisation.virtualbox.guest.enable = lib.mkDefault true;
      })
    ];

  den.schema.host.includes = [ den.aspects.virt-guest ];
}
