{ lib, ... }:
{
  den.aspects.wireguard = {
    settings = {
      options.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable wireguard server interface on this host.";
      };
      options.interface = lib.mkOption {
        type = lib.types.str;
        default = "wg0";
        description = "Wireguard interface name.";
      };
      options.listenPort = lib.mkOption {
        type = lib.types.port;
        default = 51820;
        description = "UDP port for wireguard listener.";
      };
      options.address = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "10.100.0.1/24" ];
        description = "IP addresses assigned to the wireguard interface (CIDR).";
      };
      options.privateKeyPath = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "Path to wireguard private key (typically a sops secret). null = aspect inactive.";
      };
      options.peers = lib.mkOption {
        type = lib.types.listOf (
          lib.types.submodule {
            options = {
              publicKey = lib.mkOption {
                type = lib.types.str;
                description = "Peer's wireguard public key.";
              };
              allowedIPs = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                description = "IPs allowed to be routed via this peer.";
              };
              presharedKeyFile = lib.mkOption {
                type = lib.types.nullOr lib.types.path;
                default = null;
              };
            };
          }
        );
        default = [ ];
      };
      options.openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Open UDP listenPort in the firewall.";
      };
    };

    nixos =
      { host, ... }:
      let
        cfg = host.settings.network.wireguard;
      in
      lib.mkIf (cfg.enable && cfg.privateKeyPath != null) {
        networking.wireguard.interfaces.${cfg.interface} = {
          ips = cfg.address;
          listenPort = cfg.listenPort;
          privateKeyFile = cfg.privateKeyPath;
          peers = cfg.peers;
        };

        networking.firewall.allowedUDPPorts = lib.optional cfg.openFirewall cfg.listenPort;
      };
  };
}
