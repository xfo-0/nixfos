{ lib, ... }:
{
  den.aspects.capabilities.persistent = {
    settings.options.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Host has durable storage. Gates persist/preservation routing; stateless hosts (e.g. the live ISO) omit it so no /persist symlinks are routed.";
    };
  };
}
