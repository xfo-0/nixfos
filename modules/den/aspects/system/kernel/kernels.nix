{ den, ... }:
{
  den.schema.host.includes = [ den.aspects.linux-kernel ];

  den.aspects.linux-kernel = {
    nixos =
      { pkgs, lib, ... }:
      {
        boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
      };
  };
}
