{ den, ... }:
{
  den.aspects.fingerprint.nixos =
    { config, lib, ... }:
    let
      gated = config.hardware.facter.enable;
      detected = config.hardware.facter.detected.fingerprint.enable or false;
    in
    lib.mkIf (gated && detected) {
      services.fprintd.enable = lib.mkDefault true;
    };

  den.schema.host.includes = [ den.aspects.fingerprint ];
}
