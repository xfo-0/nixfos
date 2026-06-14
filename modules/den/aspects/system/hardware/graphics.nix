{ den, ... }:
{
  den.aspects.graphics.nixos =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      det = config.hardware.facter.detected;
      gated = config.hardware.facter.enable;
      cards = config.hardware.facter.report.hardware.graphics_card or [ ];
      hasArc = lib.any (c: builtins.elem "xe" (c.driver_modules or [ ])) cards;
    in
    lib.mkMerge [
      (lib.mkIf (gated && (det.graphics.enable or false)) {
        hardware.graphics.enable32Bit = lib.mkDefault true;
      })
      (lib.mkIf (gated && (det.graphics.amd.enable or false)) {
        hardware.amdgpu.initrd.enable = lib.mkDefault true;
      })
      (lib.mkIf (gated && hasArc) {
        hardware.graphics.extraPackages = with pkgs; [
          intel-compute-runtime
          level-zero
          vpl-gpu-rt
          intel-media-driver
        ];
      })
    ];

  den.schema.host.includes = [ den.aspects.graphics ];
}
