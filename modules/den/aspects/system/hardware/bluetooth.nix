{ den, ... }:
{
  den.aspects.bluetooth.nixos =
    { config, lib, ... }:
    let
      gated = config.hardware.facter.enable;
      detected = config.hardware.facter.detected.bluetooth.enable or false;
    in
    lib.mkIf (gated && detected) {
      hardware.bluetooth.enable = lib.mkDefault true;
      hardware.bluetooth.powerOnBoot = lib.mkDefault true;
    };

  den.schema.host.includes = [ den.aspects.bluetooth ];
}
