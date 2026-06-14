{ lib, den, collectors, ... }:
{
  den.quirks.wake-targets.desc = "Records describing how to wake a host via WoL: { name; ip; mac } per host running network.wake-on-lan with a MAC declared.";

  den.policies.collect-wake-targets = collectors.collectAllHosts "wake-targets";

  den.schema.host.includes = [ den.policies.collect-wake-targets ];

  den.aspects.wake-on-lan = {
    settings = {
      options.interfaces = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Interface names to enable Wake-on-LAN on (magic-packet method). Empty derives from facter detected.dhcp.interfaces.";
        example = [ "enp4s0" ];
      };
      options.mac = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "MAC address of the WoL-enabled NIC. null = don't emit a wake-target record.";
        example = "aa:bb:cc:dd:ee:ff";
      };
    };

    wake-targets =
      { host, ... }:
      let
        cfg = host.settings.network.wake-on-lan or { };
      in
      {
        name = host.name;
        ip = host.ip;
        mac = cfg.mac or null;
      };

    nixos =
      {
        config,
        host,
        pkgs,
        ...
      }:
      let
        explicit = host.settings.network.wake-on-lan.interfaces or [ ];
        detected = config.hardware.facter.detected.dhcp.interfaces or [ ];
        ifaces = if explicit != [ ] then explicit else detected;
      in
      {
        networking.interfaces = lib.genAttrs ifaces (_: {
          wakeOnLan.enable = true;
        });

        systemd.services = lib.listToAttrs (
          map (iface: {
            name = "wake-on-lan-${iface}";
            value = {
              description = "Enable Wake-on-LAN on ${iface} (persistent)";
              wantedBy = [ "multi-user.target" ];
              after = [ "network.target" ];
              serviceConfig = {
                Type = "oneshot";
                RemainAfterExit = true;
                ExecStart = "${pkgs.ethtool}/bin/ethtool -s ${iface} wol g";
              };
            };
          }) ifaces
        );
      };
  };
}
