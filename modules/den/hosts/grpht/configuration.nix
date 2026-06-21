{
  __findFile,
  den,
  ...
}:
{
  # ── Host facts ────────────────────────────────────
  den.hosts.x86_64-linux.grpht = {
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBtNxZnFKwpTD/QFSnb61mUuNvvV6FTmnlfA3R3GsWrR grpht";
    environment = "prod";
    primaryUser = "xfo";

    settings.network.wake-on-lan = {
      mac = "58:47:ca:7b:95:8d";
    };
    settings.backup-sink.enable = true;
    settings.tailscale = {
      enable = true;
      tags = [ "tag:prod" ];
      authKeySecret = "tailscale/authkey";
      acceptDns = true;
    };
    settings.services.media.base.enable = true;
    settings.services.media.proxy.domain = "grpht.tail0df4ba.ts.net";
    settings.services.media.hd-idle.spinDownDisks = [ "ata-ST26000DM000-3Y8103_ZXA0XSXK" ];
    settings.sunshine.enable = true;
    settings.gaming.enable = true;
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
      tailscale
      backup-sink
      services.media.base
      services.media.servarr
      services.media.jellyfin
      services.media.unpackerr
      services.media.qbittorrent
      services.media.containers
      services.media.configarr
      services.media.proxy
      services.media.hd-idle
      sunshine
      gaming
    ];

    nixos.hardware.facter = {
      enable = true;
      reportPath = ./hardware/facter.json;
    };
    nixos.boot.kernelParams = [ "video=DP-1:1920x1080@60D" ];
  };
}
