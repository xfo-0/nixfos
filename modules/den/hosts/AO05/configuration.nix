{
  __findFile,
  den,
  inputs,
  ...
}:
{
  # ── Host facts ────────────────────────────────────
  # identity facts are durable; fleet derives ip from
  # den.environments.prod.networks.lan.assignments
  den.hosts.x86_64-linux.AO05 = {
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID4Y8IGMMc83HGUykK0NpbsdwetBinTzQrezWdTlXteO AO05";
    environment = "prod";
    primaryUser = "xfo";

    settings = {
      capabilities.graphical.enable = true;
      tailscale.enable = true;
      services.vaultwarden = {
        enable = true;
        domain = "ao05.tail0df4ba.ts.net";
        signupsAllowed = false;
      };
      services.binary-cache = {
        ncro.enable = true;
        harmonia = {
          enable = true;
          workers = 8;
          bind = "0.0.0.0:5000";
          publicKey = "AO05-1:29mCAXB4ohmugmD46kOGtgvHHYhGlJUX/J6uUjHjn24=";
        };
      };
    };
  };

  # ── v1 host composition (scaffolding) ─────────────
  # manual includes list — replace with neededBy/policies when den v2 lands
  den.aspects.AO05 = {
    includes = with den.aspects; [
      <boot/limine>
      (<disko> ./hardware/_disko.nix)
      {
        nixos.hardware.facter = {
          enable = true;
          reportPath = ./hardware/facter.json;
        };
      }
      services.vaultwarden
      tailscale
      services.binary-cache.harmonia
      services.binary-cache.harmonia-client
      services.binary-cache.ncro
      secrets.cache-signing
      secrets.github-token
      capabilities.graphical
      wake-client
      {
        nixos =
          {
            pkgs,
            config,
            lib,
            ...
          }:
          let
            normalUsers = lib.filterAttrs (_: u: u.isNormalUser or false) config.users.users;
            firstUserName = lib.head (builtins.attrNames normalUsers);
            niriSession = "${config.programs.niri.package}/bin/niri-session";
          in
          {
            services.greetd = {
              enable = true;
              useTextGreeter = true;
              settings = {
                terminal.vt = 1;
                default_session = {
                  user = "greeter";
                  command = "${pkgs.greetd}/bin/agreety --cmd ${niriSession}";
                };
                initial_session = {
                  user = firstUserName;
                  command = niriSession;
                };
              };
            };
          };
      }
      kmscon
      qmk
      adb
      fosi-ds2
      coolercontrol
      network.hardening
      sunshine
      <desktop-type/window-manager/niri>
    ];

  };
}
