{ inputs, lib, ... }:
{
  flake-file.inputs.vpn-confinement.url = "gh:Maroka-chan/VPN-Confinement";

  den.aspects.services.media.qbittorrent = {
    nixos =
      { host, config, ... }:
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
