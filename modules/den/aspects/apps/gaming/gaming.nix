{ lib, ... }:
{
  den.aspects.gaming = {
    settings.options.enable = lib.mkEnableOption "Steam + gamescope gaming, remote-played via Sunshine";

    nixos =
      {
        host,
        config,
        pkgs,
        ...
      }:
      let
        cfg = host.settings.gaming or { };
      in
      lib.mkIf (cfg.enable or false) {
        programs.steam = {
          enable = true;
          gamescopeSession.enable = true;
          extest.enable = true;
          extraCompatPackages = [ pkgs.proton-ge-bin ];
        };

        programs.gamescope = {
          enable = true;
          capSysNice = true;
        };

        programs.gamemode.enable = true;

        environment.systemPackages = with pkgs; [
          vulkan-tools
          mangohud
        ];

        nixpkgs.config.allowUnfree = true;

        services.sunshine.applications = lib.mkIf (config.services.sunshine.enable or false) {
          apps = [
            { name = "Desktop"; }
            {
              name = "Steam Big Picture";
              cmd = "${pkgs.gamescope}/bin/gamescope --steam -e -- steam -gamepadui";
            }
          ];
        };
      };
  };
}
