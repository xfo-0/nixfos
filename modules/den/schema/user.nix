{ __findFile, lib, config, ... }:
let
  inherit (lib) mkOption types;
  secretsRoot = config.den.secretsConfig.root;

  sshKeyType = types.submodule {
    options = {
      tag = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Tag categorizing the SSH key (e.g., 'laptop', 'workstation', 'yubikey').";
      };
      key = mkOption {
        type = types.str;
        description = "SSH public key string.";
      };
    };
  };
in
{
  den.schema.user.imports = [
    ({ name, ... }: {
      options.secretPath = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "Path to this user's secret root.";
      };
      config.secretPath = lib.mkDefault "${secretsRoot}/users/${name}";
    })
  ];

  den.schema.user.includes = [
    <den/define-user>
    (
      { user, ... }:
      {
        nixos =
          { pkgs, ... }:
          let
            shellPkgs = {
              nushell = pkgs.nushell;
              fish = pkgs.fish;
              zsh = pkgs.zsh;
              bash = pkgs.bashInteractive;
            };
            shellPkg = shellPkgs.${user.shell};
          in
          {
            users.users.${user.userName}.shell = shellPkg;
            environment.shells = [ shellPkg ];
          };
      }
    )

    <lib/ssh/authorizedKeys>
  ];

  den.schema.user.options = {
    identity = mkOption {
      type = types.submodule {
        options = {
          displayName = mkOption {
            type = types.str;
            default = "";
            description = "Display name for the user.";
          };
          email = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Email address for the user.";
          };
          gpgKey = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "GPG key ID for the user.";
          };
          sshKeys = mkOption {
            type = types.listOf sshKeyType;
            default = [ ];
            description = "SSH public keys for the user, each with an optional tag.";
          };
        };
      };
      default = { };
      description = "User identity information.";
    };

    system = mkOption {
      type = types.submodule {
        options = {
          uid = mkOption {
            type = types.nullOr types.int;
            default = null;
            description = "User ID for the Unix account.";
          };
          linger = mkOption {
            type = types.bool;
            default = false;
            description = "Enable lingering (systemd user services start without login).";
          };
          extra-features = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = "Additional feature aspects to include for this user beyond defaults.";
          };
          excluded-features = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = "Feature aspects to exclude for this user.";
          };
          include-host-features = mkOption {
            type = types.bool;
            default = false;
            description = "Whether to inherit host-level aspect features for this user.";
          };
          settings = mkOption {
            type = types.attrsOf (types.attrsOf types.anything);
            default = { };
            description = "Per-user feature settings (freeform nested namespace).";
          };
        };
      };
      default = { };
      description = "Unix account defaults and system configuration.";
    };
  };
}
