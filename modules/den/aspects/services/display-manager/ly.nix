{
  den.aspects.ly = {
    nixos =
      { lib, ... }:
      {
        services.displayManager = {
          enable = lib.mkDefault true;
          ly = {
            enable = lib.mkDefault true;
            x11Support = lib.mkDefault false;
            settings = {
              save = lib.mkDefault true;
              load = lib.mkDefault true;
              numlock = lib.mkDefault true;
              default_input = lib.mkDefault "password";
              clear_password = lib.mkDefault true;
            };
          };
        };
      };

    persist.files = [
      {
        file = "/etc/ly/save.txt";
        mode = "0644";
      }
    ];
    persistUserIgnore.files = [ "ly-session.log" ];
  };
}
