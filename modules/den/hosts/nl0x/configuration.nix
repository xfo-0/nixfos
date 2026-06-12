{ __findFile, den, ... }:
{
  # ── Host facts ────────────────────────────────────
  den.hosts.x86_64-linux.nl0x = {
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO2IOoLsIGTOjtWpGFcNx9Ue4Y7XJK4Ot/DsioOIwwEj nl0x";
    environment = "prod";

    settings.network.wireguard = {
      enable = false;
      address = [ "10.100.0.1/24" ];
      listenPort = 51820;
    };

    settings.services.home-assistant = {
      enable = false;
    };

    settings.services.vaultwarden = {
      enable = false;
      port = 8222;
      address = "127.0.0.1";
      signupsAllowed = false;
      invitationsAllowed = true;
    };

    settings.services.binary-cache.ncps = {
      hostName = "nl0x-ncps.local";
    };
  };

  # ── v1 host composition (scaffolding) ─────────────
  den.aspects.nl0x = {
    includes = with den.aspects; [
      <boot/limine>
      <desktop-type/window-manager/niri>
      kde-connect
      (<disko> ./hardware/_disko.nix)
      services.binary-cache.ncps
      services.binary-cache.harmonia-client
      wireguard
      services.home-assistant
      services.vaultwarden
      wake-client
    ];

    nixos.hardware.facter = {
      enable = true;
      report = {
        virtualisation = "none";
        hardware = {
          cpu = [
            {
              vendor_name = "GenuineIntel";
              features = [ "vmx" ];
            }
          ];
          graphics_card = [
            {
              driver_modules = [ "i915" ];
              vendor.name = "Intel Corporation";
            }
          ];
          monitor = [ { } ];
        };
      };
    };
  };
}
