{ den, ... }:
{
  den.aspects.intel-xpu.nixos =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      gated = config.hardware.facter.enable;
      cards = config.hardware.facter.report.hardware.graphics_card or [ ];
      hasArc = lib.any (c: builtins.elem "xe" (c.driver_modules or [ ])) cards;
    in
    lib.mkIf (gated && hasArc) {
      programs.nix-ld.libraries = with pkgs; [
        stdenv.cc.cc.lib
        zlib
        level-zero
        ocl-icd
        numactl
        libxml2
      ];

      environment.systemPackages = [ pkgs.uv ];
    };

  den.schema.host.includes = [ den.aspects.intel-xpu ];
}
