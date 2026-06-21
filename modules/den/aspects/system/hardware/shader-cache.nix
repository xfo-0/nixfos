{ ... }:
{
  den.aspects.shader-cache.persistUser =
    { hmConfig, osConfig, ... }:
    let
      det = osConfig.hardware.facter.detected;
      drivers = det.boot.graphics.kernelModules or [ ];
      hasAmdGpu = det.graphics.amd.enable or false;
      hasIntelGpu = builtins.elem "i915" drivers;
      gated = osConfig.hardware.facter.enable;
    in
    {
      directories =
        (
          if gated && (hasAmdGpu || hasIntelGpu) then
            [ "${hmConfig.xdg.cacheHome}/mesa_shader_cache" ]
          else
            [ ]
        )
        ++ (if gated && hasAmdGpu then [ "${hmConfig.xdg.cacheHome}/radv_builtin_shaders" ] else [ ]);
    };
}
