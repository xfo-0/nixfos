{
  __findFile,
  den,
  ...
}:
{
  # ── Host facts ────────────────────────────────────
  den.hosts.x86_64-linux.grpht = {
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOXAMJ9irvgKNxRmB1Dmg57VNAeRdqN65OSPTYO4nylG grpht";
    environment = "prod";
    primaryUser = "xfo";

    settings.network.wake-on-lan = {
      mac = "00:00:00:00:00:00";
    };
    settings.backup-sink.enable = true;
    settings.services.media.base.enable = true;
  };

  # ── v1 host composition (scaffolding) ─────────────
  den.aspects.grpht = {
    includes = with den.aspects; [
      <boot/limine>
      <desktop-type/window-manager/niri>
      (<disko> ./hardware/_disko.nix)
      services.binary-cache.harmonia
      services.binary-cache.harmonia-client
      wake-on-lan
      wake-client
      backup-sink
      services.media.base
      services.media.servarr
      services.media.jellyfin
      services.media.unpackerr
      services.media.qbittorrent
      services.media.containers
      services.media.configarr
      services.media.proxy
    ];

    nixos.hardware.facter = {
      enable = true;
      reportPath = ./hardware/facter.json;
    };
  };
}
