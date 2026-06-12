{ den, ... }:
{
  den.aspects.graphics.nixos =
    { config, lib, ... }:
    let
      det = config.hardware.facter.detected;
      gated = config.hardware.facter.enable;
    in
    lib.mkMerge [
      (lib.mkIf (gated && (det.graphics.enable or false)) {
        hardware.graphics.enable32Bit = lib.mkDefault true;
      })
      (lib.mkIf (gated && (det.graphics.amd.enable or false)) {
        hardware.amdgpu.initrd.enable = lib.mkDefault true;
      })
    ];

  den.schema.host.includes = [ den.aspects.graphics ];
}
