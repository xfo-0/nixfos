{
  den.aspects.qmk = {
    nixos =
      { pkgs, lib, ... }:
      {
        hardware.keyboard.qmk.enable = lib.mkDefault true;
        services.udev.packages = [ pkgs.vial ];
        environment.systemPackages = with pkgs; [
          qmk
          vial
        ];
      };
  };
}
