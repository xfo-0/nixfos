{
  den,
  lib,
  routes,
  ...
}:
{
  den.classes.nushellExternalCompleters.description = "Nushell per-command external completers (forwarded to programs.nushell.externalCompleters)";
  den.classes.nushellExternalCompleterPrimary.description = "Nushell primary external completer — must define $primary_completer (forwarded to programs.nushell)";
  den.classes.nushellExternalCompleterFallback.description = "Nushell fallback external completer — must define $fallback_completer (forwarded to programs.nushell)";

  den.schema.user.includes = [
    {
      homeManager = {
        options.programs.nushell = {
          externalCompleters = lib.mkOption {
            type = lib.types.attrsOf lib.types.lines;
            default = { };
          };
          externalCompleterPrimary = lib.mkOption {
            type = lib.types.nullOr lib.types.lines;
            default = null;
          };
          externalCompleterFallback = lib.mkOption {
            type = lib.types.nullOr lib.types.lines;
            default = null;
          };
        };
      };
    }
  ];

  den.policies.nushell-external-completers-route = routes.mkHmRoute {
    fromClass = "nushellExternalCompleters";
    hmPath = [
      "programs"
      "nushell"
      "externalCompleters"
    ];
  };
  den.policies.nushell-external-completer-primary-route = routes.mkHmRoute {
    fromClass = "nushellExternalCompleterPrimary";
    hmPath = [
      "programs"
      "nushell"
    ];
  };
  den.policies.nushell-external-completer-fallback-route = routes.mkHmRoute {
    fromClass = "nushellExternalCompleterFallback";
    hmPath = [
      "programs"
      "nushell"
    ];
  };

  den.default.includes = [
    den.policies.nushell-external-completers-route
    den.policies.nushell-external-completer-primary-route
    den.policies.nushell-external-completer-fallback-route
  ];

  den.aspects.nushell = {
    homeManager =
      { config, lib, ... }:
      let
        cfg = config.programs.nushell;
        perCommand = lib.concatStringsSep "\n" (
          lib.mapAttrsToList (name: code: "      ${name}: (${code})") cfg.externalCompleters
        );
      in
      {
        programs.nushell.enable = lib.mkDefault true;

        xdg.configFile."nushell/external-completers.generated.nu".text = ''
          ${
            if cfg.externalCompleterPrimary != null then
              cfg.externalCompleterPrimary
            else
              "let primary_completer = {|spans| null }"
          }

          ${
            if cfg.externalCompleterFallback != null then
              cfg.externalCompleterFallback
            else
              "let fallback_completer = {|spans| null }"
          }

          let per_command_completers = {
          ${perCommand}
          }

          let external_completer = {|spans|
              let cmd = ($spans | first)
              if ($cmd in ($per_command_completers | columns)) {
                  do ($per_command_completers | get $cmd) $spans
              } else {
                  let primary = (do $primary_completer $spans)
                  if ($primary | is-not-empty) { $primary } else { do $fallback_completer $spans }
              }
          }

          $env.config = ($env.config? | default {})
          $env.config.completions = ($env.config.completions? | default {})
          $env.config.completions.external = {
              enable: true
              max_results: 200
              completer: $external_completer
          }
        '';

        programs.nushell.extraEnv = ''
          $env.PATH = ($env.PATH | prepend (
              [ '~/.local/bin',
                '~/.cargo/bin'
              ] | path expand
          ) | uniq)
        '';

        programs.nushell.extraConfig = ''
          $env.config = {
          show_banner: false
          use_kitty_protocol: true
          buffer_editor: "nvim"

          table: {
            mode: "none"
            show_empty: false
            padding: {
            left: 0
            right: 0
            }
            trim: {
            methodology: "truncating"
            truncating_suffix: "$"
            }
          }
          filesize: {
            unit: metric
          }
          keybindings: [
            {
            name: jump_dir
            modifier: control
            keycode: enter
            mode: emacs
            event: {
              send: executehostcommand,
              cmd: "zi"
              }
            }
            {
            name: tui_file_manager
            modifier: control
            keycode: space
            mode: emacs
            event: {
              send: executehostcommand,
              cmd: "y"
              }
            }
            {
            name: clear
            modifier: control
            keycode: delete
            mode: emacs
            event: {
              send: executehostcommand,
              cmd: "clear"
              }
            }
          ]
          }

          source ${config.xdg.configFile."nushell/external-completers.generated.nu".source}

          $env.config = ($env.config? | default {})
          $env.config.hooks = ($env.config.hooks? | default {})
          $env.config.hooks.pre_prompt = (
              $env.config.hooks.pre_prompt?
              | default []
              | append {||
                  direnv export json
                  | from json --strict
                  | default {}
                  | items {|key, value|
                      let value = do (
                          {
                            "PATH": {
                              from_string: {|s| $s | split row (char esep) | path expand --no-symlink }
                              to_string: {|v| $v | path expand --no-symlink | str join (char esep) }
                            }
                          }
                          | merge ($env.ENV_CONVERSIONS? | default {})
                          | get ([[value, optional, insensitive]; [$key, true, true] [from_string, true, false]] | into cell-path)
                          | if ($in | is-empty) { {|x| $x} } else { $in }
                      ) $value
                      return [ $key $value ]
                  }
                  | into record
                  | load-env
              }
          )
        '';
      };

    persistUser =
      { hmConfig, ... }:
      {
        files = [
          {
            file = "${hmConfig.xdg.configHome}/nushell/history.txt";
            how = "symlink";
          }
        ];
      };

    persistUserIgnore =
      { hmConfig, ... }:
      {
        files = [
          "${hmConfig.xdg.configHome}/nushell/plugin.msgpackz"
        ];
      };

    persistUserTmp =
      { hmConfig, ... }:
      {
        "${hmConfig.xdg.configHome}" = { };
        "${hmConfig.xdg.configHome}/nushell" = { };
      };
  };
}
