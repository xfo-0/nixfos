{ lib, ... }:
{
  den.aspects.sunshine = {
    settings.options = {
      enable = lib.mkEnableOption "Sunshine stream host (Moonlight) + headless autologin niri session";
      renderNode = lib.mkOption {
        type = lib.types.str;
        default = "/dev/dri/renderD128";
        description = "DRM render node for VAAPI encode (the discrete/stream GPU).";
      };
    };

    nixos =
      {
        host,
        config,
        pkgs,
        ...
      }:
      let
        cfg = host.settings.sunshine or { };
        niriSession = "${config.programs.niri.package}/bin/niri-session";
      in
      lib.mkIf (cfg.enable or false) {
        services.greetd = {
          enable = true;
          settings = {
            default_session = {
              user = "greeter";
              command = "${pkgs.greetd}/bin/agreety --cmd ${niriSession}";
            };
            initial_session = {
              user = host.primaryUser;
              command = niriSession;
            };
          };
        };

        services.sunshine = {
          enable = true;
          openFirewall = false;
          capSysAdmin = true;
          autoStart = true;
          settings.adapter_name = cfg.renderNode or "/dev/dri/renderD128";
        };

        networking.firewall.interfaces.tailscale0 = {
          allowedTCPPorts = [
            47984
            47989
            47990
            48010
          ];
          allowedUDPPorts = [
            47998
            47999
            48000
            48010
          ];
        };
      };
  };
}
