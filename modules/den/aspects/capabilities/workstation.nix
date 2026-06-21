{ lib, ... }:
{
  den.aspects.capabilities.workstation = {
    settings.options.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Host is a full workstation. Gates heavy productivity apps (cad, messaging); lean hosts (e.g. the live ISO) omit it.";
    };
  };
}
