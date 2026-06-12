{ lib, ... }:
{
  den.aspects.tailscale = {
    settings = {
      options.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable tailscale on this host (join interactively with `tailscale up`).";
      };
    };

    nixos =
      { host, ... }:
      let
        cfg = host.settings.tailscale or { };
      in
      lib.mkIf (cfg.enable or false) {
        services.tailscale = {
          enable = true;
          openFirewall = true;
          useRoutingFeatures = "client";
        };
        networking.firewall.trustedInterfaces = [ "tailscale0" ];
      };

    persist =
      { host, ... }:
      let
        cfg = host.settings.tailscale or { };
      in
      {
        directories = lib.optionals (cfg.enable or false) [
          {
            directory = "/var/lib/tailscale";
            mode = "0700";
          }
        ];
      };
  };
}
