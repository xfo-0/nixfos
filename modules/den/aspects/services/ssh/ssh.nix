{ den, ... }:
{
  den.schema.host.includes = [ den.aspects.ssh ];
  den.schema.user.includes = [ den.aspects.ssh.client ];

  den.aspects.ssh = {
    includes = [
      den.aspects.ssh.openssh
      den.aspects.ssh.knownHosts
      den.aspects.ssh.client
    ];

    knownHosts = {
      nixos =
        {
          host,
          host-info,
          lib,
          ...
        }:
        let
          peers = lib.filter (h: h.name != host.name) host-info;
          peerHostSettings =
            uname:
            builtins.listToAttrs (
              map (h: {
                name = "Host ${h.name}";
                value = {
                  Hostname = h.ip;
                  User = uname;
                  IdentityFile = "~/.ssh/id_ed25519";
                  IdentitiesOnly = true;
                };
              }) peers
            );
        in
        {
          services.openssh.knownHosts = builtins.listToAttrs (
            map (h: {
              inherit (h) name;
              value = {
                hostNames = [
                  h.name
                  h.ip
                ];
                inherit (h) publicKey;
              };
            }) host-info
          );
        }
        // lib.optionalAttrs (host.users != { }) {
          home-manager.users = lib.mapAttrs (uname: _: {
            programs.ssh = {
              enableDefaultConfig = false;
              settings = peerHostSettings uname;
            };
          }) host.users;
        };
    };

    openssh = {
      nixos =
        { lib, ... }:
        {
          services.openssh = {
            enable = lib.mkDefault true;
            openFirewall = lib.mkDefault true;
            settings = {
              PermitRootLogin = lib.mkDefault "no";
              PasswordAuthentication = lib.mkDefault false;
              KbdInteractiveAuthentication = lib.mkDefault false;
            };
          };
        };

      persist =
        { lib, ... }:
        {
          files =
            lib.map
              (path: {
                file = path;
                how = "symlink";
                inInitrd = true; # Needed for `sops-nix` to decrypt host secrets pre-stage-2
                configureParent = true;
              })
              [
                "/etc/ssh/ssh_host_ed25519_key"
                "/etc/ssh/ssh_host_ed25519_key.pub"
              ];
        };
    };

    client = {
      persistUser =
        { ... }:
        {
          directories = [
            {
              directory = ".ssh";
              how = "symlink";
              mode = "0700";
              createLinkTarget = true;
            }
          ];
        };

      homeManager.programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        settings = {
          "Host github.com" = {
            IdentityFile = "~/.ssh/id_ed25519";
            IdentitiesOnly = true;
          };
          "Host *" = {
            ForwardAgent = false;
            ServerAliveInterval = 0;
            ServerAliveCountMax = 3;
            Compression = false;
            AddKeysToAgent = false;
            HashKnownHosts = false;
            UserKnownHostsFile = "~/.ssh/known_hosts";
            ControlMaster = false;
            ControlPath = "~/.ssh/master-%r@%n:%p";
            ControlPersist = false;
          };
        };
      };
    };
  };
}
