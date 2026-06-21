{
  den.aspects.adb = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [ android-tools ];
      };

    user = {
      extraGroups = [ "adbusers" ];
    };
  };
}
