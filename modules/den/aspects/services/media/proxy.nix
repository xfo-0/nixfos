{ lib, ... }:
{
  den.aspects.services.media.proxy = {
    settings.options.domain = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Full tailnet MagicDNS name of this host for the media reverse proxy (e.g. grpht.<tailnet>.ts.net). null disables the proxy. Subdomains are not routable on a tailnet, so apps are served as path prefixes (servarr) or dedicated TLS ports.";
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
        domain = proxyCfg.domain or null;
        qbAddr = proxyCfg.qbittorrentNetnsAddr or "192.168.15.1";

        pathApps = {
          sonarr = 8989;
          radarr = 7878;
          lidarr = 8686;
          readarr = 8787;
          prowlarr = 9696;
        };

        portApps = {
          "8920" = "127.0.0.1:8096";
          "5443" = "127.0.0.1:5055";
          "6443" = "127.0.0.1:6767";
          "8443" = "${qbAddr}:8080";
        };

        tlsBlock = ''
          tls {
            get_certificate tailscale
          }
        '';

        pathBlocks = lib.concatStringsSep "\n" (
          lib.mapAttrsToList (name: port: ''
            handle /${name}* {
              reverse_proxy 127.0.0.1:${toString port}
            }
          '') pathApps
        );

        portVhosts = lib.mapAttrs' (
          listenPort: target:
          lib.nameValuePair "${domain}:${listenPort}" {
            extraConfig = tlsBlock + "reverse_proxy ${target}";
          }
        ) portApps;
      in
      lib.mkIf ((cfg.enable or false) && (domain != null)) {
        services.caddy = {
          enable = true;
          virtualHosts = {
            "${domain}".extraConfig = tlsBlock + pathBlocks;
          }
          // portVhosts;
        };

        services.tailscale.permitCertUid = "caddy";

        systemd.services = lib.mapAttrs (
          name: _: {
            environment."${lib.toUpper name}__SERVER__URLBASE" = "/${name}";
          }
        ) pathApps;

        networking.firewall.interfaces.tailscale0.allowedTCPPorts = [
          443
        ]
        ++ map lib.toInt (lib.attrNames portApps);
      };
  };
}
