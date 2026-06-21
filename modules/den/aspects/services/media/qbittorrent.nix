{ inputs, lib, ... }:
{
  flake-file.inputs.vpn-confinement.url = "gh:Maroka-chan/VPN-Confinement";

  den.aspects.services.media.qbittorrent = {
    nixos =
      { host, config, pkgs, ... }:
      let
        cfg = host.settings.services.media.base or { };
      in
      {
        imports = [ inputs.vpn-confinement.nixosModules.default ];

        config = lib.mkIf (cfg.enable or false) {
          sops.secrets."proton-wg.conf" = {
            sopsFile = "${host.secretPath}/proton-wg.conf";
            format = "binary";
          };

          vpnNamespaces.pvpn = {
            enable = true;
            wireguardConfigFile = config.sops.secrets."proton-wg.conf".path;
            accessibleFrom = [
              "127.0.0.1/32"
              "100.64.0.0/10"
            ];
            portMappings = [
              {
                from = 8080;
                to = 8080;
              }
            ];
          };

          services.qbittorrent = {
            enable = true;
            user = "qbittorrent";
            group = "media";
            webuiPort = 8080;
            openFirewall = false;
            profileDir = "/var/lib/qBittorrent";
          };

          systemd.services.qbittorrent = {
            serviceConfig.UMask = lib.mkForce "0002";
            vpnConfinement = {
              enable = true;
              vpnNamespace = "pvpn";
            };
          };

          systemd.services.natpmp-pvpn = {
            description = "Proton NAT-PMP port-forward -> qBittorrent listen port";
            after = [ "qbittorrent.service" ];
            bindsTo = [ "qbittorrent.service" ];
            wantedBy = [ "multi-user.target" ];
            vpnConfinement = {
              enable = true;
              vpnNamespace = "pvpn";
            };
            path = with pkgs; [
              libnatpmp
              curl
              gnugrep
              coreutils
            ];
            serviceConfig = {
              Restart = "always";
              RestartSec = "10";
            };
            script = ''
              set +e
              gw=10.2.0.1
              last=""
              while true; do
                natpmpc -a 1 0 udp 60 -g "$gw" > /dev/null 2>&1
                out=$(natpmpc -a 1 0 tcp 60 -g "$gw" 2>/dev/null)
                port=$(echo "$out" | grep -oP 'Mapped public port \K[0-9]+' | head -n1)
                if [ -n "$port" ] && [ "$port" != "$last" ]; then
                  if curl -fsS "http://127.0.0.1:8080/api/v2/app/setPreferences" \
                       --data-urlencode "json={\"listen_port\":$port,\"random_port\":false,\"upnp\":false}"; then
                    last="$port"
                  fi
                fi
                sleep 45
              done
            '';
          };
        };
      };

    persistReplicated =
      { host, ... }:
      let
        cfg = host.settings.services.media.base or { };
      in
      {
        directories = lib.optionals (cfg.enable or false) [
          {
            directory = "/var/lib/qBittorrent";
            user = "qbittorrent";
            group = "media";
            mode = "0700";
          }
        ];
      };
  };
}
