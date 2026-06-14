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
    ];

    nixos.hardware.facter = {
      enable = true;
      reportPath = ./hardware/facter.json;
    };
  };
}
