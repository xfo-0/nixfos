{ den, ... }:
{
  den.aspects.camera-ipu6.nixos =
    {
      config,
      lib,
      host,
      ...
    }:
    let
      gated = config.hardware.facter.enable;
      detected = config.hardware.facter.detected.camera.ipu6.enable or false;
      platform = host.settings.camera.ipu6.platform or null;
    in
    lib.mkIf (gated && detected) {
      assertions = [
        {
          assertion = platform != null;
          message = "camera-ipu6: facter detected an IPU6 camera; set host settings.camera.ipu6.platform to one of: ipu6 (Tiger Lake), ipu6ep (Alder/Raptor Lake), ipu6epmtl (Meteor Lake).";
        }
      ];

      hardware.ipu6 = lib.mkIf (platform != null) {
        enable = true;
        inherit platform;
      };
    };

  den.schema.host.includes = [ den.aspects.camera-ipu6 ];
}
