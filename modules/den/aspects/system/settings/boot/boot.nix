{
  den.aspects.boot = {
    _.grub = {
      nixos =
        { lib, ... }:
        {
          boot.loader.grub = {
            enable = lib.mkDefault true;
            useOSProber = lib.mkDefault true;
          };
        };
    };

    _.systemd = {
      nixos =
        { lib, ... }:
        {
          boot = {
            initrd = {
              systemd.enable = lib.mkDefault true;
            };
            loader = {
              systemd-boot.enable = lib.mkDefault true;
              efi.canTouchEfiVariables = lib.mkDefault true;
            };
          };
        };
    };

    _.limine = {
      nixos =
        { lib, ... }:
        {
          boot.loader = {
            limine = {
              enable = lib.mkDefault true;
              efiSupport = lib.mkDefault true;
              # biosSupport = !uefi;
              maxGenerations = 50;
            };
            efi.canTouchEfiVariables = lib.mkDefault true;
          };
        };
    };
  };
}
