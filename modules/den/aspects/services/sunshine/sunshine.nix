{ lib, ... }:
{
  den.aspects.sunshine = {
    tailnet-grant =
      { host, ... }:
      lib.optional (host.settings.sunshine.enable or false) {
        from = "devices";
        ports = "47984,47989,47990,47998-48000,48010";
      };

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
