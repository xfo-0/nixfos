{ self, lib, ... }:
{
  perSystem =
    { system, pkgs, ... }:
    {
      checks = lib.mapAttrs' (
        name: cfg:
        lib.nameValuePair "host-${name}" (
          pkgs.writeText "eval-host-${name}" (
            builtins.unsafeDiscardStringContext cfg.config.system.build.toplevel.drvPath
          )
        )
      ) (lib.filterAttrs (_: cfg: cfg.pkgs.system == system) self.nixosConfigurations);
    };
}
