{ den, lib, ... }:
{
  den.aspects.ananicy = {
    includes = [
      den.aspects.ananicy.enable
    ];

    enable = {
      nixos =
        { pkgs, lib, ... }:
        {
          services.ananicy = {
            enable = lib.mkDefault true;
            package = lib.mkDefault pkgs.ananicy-cpp;
          };
        };
    };
  };
}
