{ lib, ... }:
{
  options.flake.lib = lib.mkOption {
    type = with lib.types; attrsOf unspecified;
    default = { };
  };

  config.flake.lib = {
    applyDefaults = lib.mapAttrs (_: value: lib.mkDefault value);

    # ONLY USE THIS FOR PURE DATA FILES (i.e., `programs.niri.settings` from niri-flake)
    applyDefaultsRecursive = lib.mapAttrsRecursive (_: value: lib.mkDefault value);
  };
}
