{ lib, ... }:
{
  den.aspects.capabilities.graphical = {
    settings.options.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Host advertises a graphical/desktop capability. Gates promotion of user graphical-system modules (e.g. stylix) to nixos.";
    };
  };
}
