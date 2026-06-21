{
  __findFile,
  den,
  inputs,
  ...
}:
{
  # ── Host facts ────────────────────────────────────
  den.hosts.x86_64-linux.nl0x = {
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAwpMZ5qN1X5Gclzlb5w7S/do8FPbaJJdeJHapoK9/El nl0x";
    environment = "prod";

    settings.tailscale = {
      enable = true;
      tags = [ "tag:prod" ];
      authKeySecret = "tailscale/authkey";
      acceptDns = false;
    };

    settings.services.atuin-server.enable = true;

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
      (<disko> ./hardware/_disko.nix)
      services.binary-cache.ncps
      services.binary-cache.harmonia-client
      tailscale
      services.atuin-server
      wireguard
      services.home-assistant
      services.vaultwarden
      wake-client
    ];

    nixos = {
      hardware.facter = {
        enable = true;
        reportPath = ./hardware/facter.json;
      };
      networking.networkmanager.enable = true;
      users.users.xfo.extraGroups = [ "networkmanager" ];
    };
  };
}
