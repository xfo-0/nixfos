{
  den.aspects.sunshine = {
    nixos =
      { lib, ... }:
      {
        services.sunshine = {
          enable = lib.mkDefault false;
          autoStart = lib.mkDefault false;
          openFirewall = lib.mkDefault false;
          capSysAdmin = lib.mkDefault false;
        };
      };
  };
}
