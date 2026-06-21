{
  lib,
  den,
  __findFile,
  inputs,
  config,
  ...
}:
let
  secretsRoot = config.den.secretsConfig.root;
  inherit (den.lib.aspects.fx.keyClassification) structuralKeysSet;
  classKeys = den.classes or { };
  quirkKeys = den.quirks or { };
  skipKey =
    k: structuralKeysSet ? ${k} || classKeys ? ${k} || quirkKeys ? ${k} || lib.hasPrefix "_" k;

  isPlainAttrs = v: builtins.isAttrs v && !(v ? __functor);

  browserSlugs = builtins.attrNames (
    lib.filterAttrs (k: v: isPlainAttrs v && !(skipKey k)) (den.aspects.browser or { })
  );

  reshapeSettings = raw: {
    imports = raw.imports or [ ];
    config = raw.config or { };
    options = removeAttrs raw [
      "imports"
      "config"
    ];
  };

  buildSettingsModule =
    aspects:
    let
      children = lib.filterAttrs (k: v: isPlainAttrs v && !(skipKey k)) aspects;
      withSettings = lib.filterAttrs (_: a: isPlainAttrs a && a ? settings) aspects;
    in
    lib.types.submodule {
      freeformType = lib.types.attrsOf lib.types.anything;
      options =
        lib.mapAttrs (
          name: aspect:
          lib.mkOption {
            type = lib.types.submodule (reshapeSettings aspect.settings);
            default = { };
            description = "Settings for the ${name} aspect";
          }
        ) withSettings
        //
          lib.mapAttrs
            (
              name: child:
              lib.mkOption {
                type = buildSettingsModule child;
                default = { };
                description = "Settings under ${name}";
              }
            )
            (
              lib.filterAttrs (
                k: v:
                !(withSettings ? ${k})
                && isPlainAttrs v
                && !(skipKey k)
                && lib.any (ck: isPlainAttrs (v.${ck} or null) && (v.${ck} ? settings)) (builtins.attrNames v)
              ) children
            );
    };

  settingsType = buildSettingsModule (den.aspects or { });
in
{
  den.schema.host.imports = [
    ({ name, ... }: {
      config.secretPath = lib.mkDefault "${secretsRoot}/hosts/${name}";
    })
  ];

  den.schema.host.includes = [
    <den/hostname>
    <pkgs-cfg>
    <sops-infra>
  ];

  den.schema.host.options = {
    ip = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Host's primary LAN IP address. null for transient hosts (installer ISO, etc.).";
    };
    publicKey = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Host's SSH ed25519 public key. null for transient hosts.";
    };
    environment = lib.mkOption {
      type = lib.types.str;
      default = "prod";
      description = "Environment name that this host belongs to. Used by scope-engine settings cascade.";
    };
    secretPath = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to this host's secret root.";
    };
    settings = lib.mkOption {
      type = settingsType;
      default = { };
      description = "Per-aspect typed settings, auto-discovered from den.aspects.<path>.settings.";
    };
    primaryUser = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "userName of the host's primary/owning user. Set as a host fact; read by promoteToHost to gate user->nixos module promotion. null on hosts with no primary user.";
    };
    system-access-groups = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "System-scoped groups that grant Unix account creation on this host (host-level override merged with the environment's grants by the ACL).";
    };
  };

  den.schema.user.options = {
    editor = lib.mkOption {
      type = lib.types.str;
      default = "nvim";
      description = "Default editor";
    };
    terminal = lib.mkOption {
      type = lib.types.str;
      default = "rio";
      description = "Default terminal emulator command";
    };

    shell = lib.mkOption {
      type = lib.types.enum [
        "nushell"
        "fish"
        "zsh"
        "bash"
      ];
      default = "nushell";
      description = "Login shell choice";
    };

    colorscheme = lib.mkOption {
      type = lib.types.str;
      default = "kanso-ink";
      description = "Colorscheme slug. Aspects look this up from their own theme tables.";
    };

    wm = lib.mkOption {
      type = lib.types.enum [
        "niri"
      ];
      default = "niri";
      description = "Preferred window manager";
    };

    browsers = lib.mkOption {
      type = lib.types.listOf (lib.types.enum browserSlugs);
      default = [
        "floorp"
        "chrome"
      ];
      description = "Browsers to install. Enum auto-derived from den.aspects.browser.<slug>.";
    };

    browser = lib.mkOption {
      type = lib.types.enum browserSlugs;
      default = "floorp";
      description = "Default browser. Enum auto-derived from den.aspects.browser.<slug>.";
    };
  };
}
