{
  den.aspects.kmscon.nixos =
    { lib, ... }:
    {
      services.kmscon = {
        enable = true;
        config.hwaccel = lib.mkDefault true;
      };
    };
}
