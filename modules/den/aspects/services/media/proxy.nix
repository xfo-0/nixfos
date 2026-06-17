{ lib, ... }:
{
  den.aspects.services.media.proxy = {
    settings.options.domain = lib.mkOption {
      type = lib.types.str;
      default = "grpht.ts.net";
      description = "Tailnet MagicDNS suffix for media reverse-proxy vhosts (e.g. grpht.<tailnet>.ts.net).";
    };
    settings.options.qbittorrentNetnsAddr = lib.mkOption {
      type = lib.types.str;
      default = "192.168.15.1";
      description = "vpn-confinement netns address where qBittorrent's WebUI is reachable from the host; host-local loopback bypasses the netns PREROUTING DNAT.";
    };

    nixos =
      { host, ... }:
      let
        cfg = host.settings.services.media.base or { };
        proxyCfg = host.settings.services.media.proxy or { };
        domain = proxyCfg.domain or "grpht.ts.net";
        qbAddr = proxyCfg.qbittorrentNetnsAddr or "192.168.15.1";
        hostLocal = {
          sonarr = 8989;
          radarr = 7878;
          lidarr = 8686;
          readarr = 8787;
          prowlarr = 9696;
          bazarr = 6767;
          jellyfin = 8096;
          jellyseerr = 5055;
        };
      in
      lib.mkIf (cfg.enable or false) {
        services.caddy = {
          enable = true;
          virtualHosts = (lib.mapAttrs' (
            name: port:
            lib.nameValuePair "${name}.${domain}" {
              extraConfig = "reverse_proxy 127.0.0.1:${toString port}";
            }
          ) hostLocal)
          // {
            "qbittorrent.${domain}".extraConfig = "reverse_proxy ${qbAddr}:8080";
          };
        };
        networking.firewall.interfaces.tailscale0.allowedTCPPorts = [
          80
          443
        ];
      };
  };
}
