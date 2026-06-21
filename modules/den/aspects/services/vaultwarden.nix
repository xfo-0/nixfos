{ lib, ... }:
{
  den.aspects.services.vaultwarden = {
    tailnet-grant =
      { host, ... }:
      lib.optional (host.settings.services.vaultwarden.enable or false) {
        from = "devices";
        ports = "80,443";
      };

    settings = {
      options.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable vaultwarden service on this host.";
      };
      options.port = lib.mkOption {
        type = lib.types.port;
        default = 8222;
      };
      options.address = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1";
        description = "Bind address. Use 0.0.0.0 or :: for LAN access; keep 127.0.0.1 when reverse-proxied.";
      };
      options.domain = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Public-facing domain (e.g. vault.example.com). null = LAN-only.";
      };
      options.signupsAllowed = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Allow new user self-registration. Default false (admin must invite).";
      };
      options.invitationsAllowed = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Allow admin to invite new users.";
      };
      options.webVaultEnabled = lib.mkOption {
        type = lib.types.bool;
        default = true;
      };
      options.openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Open the listen port in nixos firewall.";
      };
      options.dataDir = lib.mkOption {
        type = lib.types.path;
        default = "/var/lib/vaultwarden";
        description = "Persistence directory.";
      };
      options.environmentFiles = lib.mkOption {
        type = lib.types.listOf lib.types.path;
        default = [ ];
        description = "Paths to env files containing ADMIN_TOKEN, SMTP_PASSWORD, etc. Typically sops secret paths.";
      };
      options.extraConfig = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = { };
        description = "Extra services.vaultwarden.config entries (uppercased env var names).";
      };
      options.backup.enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Daily sqlite-safe backup of the data dir.";
      };
      options.backup.dir = lib.mkOption {
        type = lib.types.path;
        default = "/persist/backups/vaultwarden";
      };
      options.backup.keepDays = lib.mkOption {
        type = lib.types.int;
        default = 30;
      };
    };

    nixos =
      { host, pkgs, ... }:
      let
        cfg = host.settings.services.vaultwarden or { };
        port = cfg.port or 8222;
        dataDir = cfg.dataDir or "/var/lib/vaultwarden";
        domain = cfg.domain or null;
        backup = cfg.backup or { };
      in
      lib.mkIf (cfg.enable or false) {
        services.vaultwarden = {
          enable = true;
          dbBackend = "sqlite";
          environmentFile = lib.mkIf ((cfg.environmentFiles or [ ]) != [ ]) cfg.environmentFiles;
          domain = if domain != null then domain else "localhost:8443";
          config = {
            ROCKET_ADDRESS = cfg.address or "127.0.0.1";
            ROCKET_PORT = port;
            SIGNUPS_ALLOWED = cfg.signupsAllowed or false;
            INVITATIONS_ALLOWED = cfg.invitationsAllowed or true;
            WEB_VAULT_ENABLED = cfg.webVaultEnabled or true;
            DATA_FOLDER = dataDir;
          }
          // (cfg.extraConfig or { });
        };

        networking.firewall.allowedTCPPorts = lib.optional (cfg.openFirewall or false) port;

        systemd.services.vaultwarden-backup = lib.mkIf (backup.enable or true) {
          description = "vaultwarden sqlite-safe backup";
          serviceConfig.Type = "oneshot";
          path = [
            pkgs.sqlite
            pkgs.coreutils
            pkgs.findutils
            pkgs.gnutar
            pkgs.gzip
          ];
          script = ''
            dir=${lib.escapeShellArg (backup.dir or "/persist/backups/vaultwarden")}
            data=${lib.escapeShellArg dataDir}
            install -d -m 700 "$dir"
            stamp=$(date +%F-%H%M)
            sqlite3 "$data/db.sqlite3" ".backup '$dir/db-$stamp.sqlite3'"
            tar -czf "$dir/files-$stamp.tar.gz" -C "$data" \
              --exclude="db.sqlite3*" --exclude=icon_cache .
            find "$dir" -type f -mtime +${toString (backup.keepDays or 30)} -delete
          '';
        };
        systemd.timers.vaultwarden-backup = lib.mkIf (backup.enable or true) {
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnCalendar = "daily";
            Persistent = true;
            RandomizedDelaySec = "15m";
          };
        };

        services.caddy = {
          enable = lib.mkDefault true;
          virtualHosts =
            {
              "https://localhost:8443".extraConfig = ''
                tls internal
                reverse_proxy 127.0.0.1:${toString port}
              '';
            }
            // lib.optionalAttrs (domain != null) {
              "${domain}".extraConfig = ''
                tls {
                  get_certificate tailscale
                }
                reverse_proxy 127.0.0.1:${toString port}
              '';
            };
        };
        services.tailscale.permitCertUid = lib.mkIf (domain != null) "caddy";
      };

    persist =
      { host, ... }:
      let
        cfg = host.settings.services.vaultwarden or { };
      in
      {
        directories = lib.optionals (cfg.enable or false) [
          {
            directory = "/var/lib/caddy";
            user = "caddy";
            group = "caddy";
            mode = "0700";
          }
        ];
      };

    persistReplicated =
      { host, ... }:
      let
        cfg = host.settings.services.vaultwarden or { };
      in
      {
        directories = lib.optionals (cfg.enable or false) [
          {
            directory = cfg.dataDir or "/var/lib/vaultwarden";
            user = "vaultwarden";
            group = "vaultwarden";
            mode = "0700";
          }
        ];
      };
  };
}
