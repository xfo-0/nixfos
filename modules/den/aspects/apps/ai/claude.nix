{ den, ... }:
{
  den.aspects.claude = {
    includes = [
      den.aspects.ai.extensions
    ];

    homeManager =
      {
        config,
        inputs',
        lib,
        pkgs,
        ...
      }:
      let
        claudeDir = "${config.home.homeDirectory}/.claude";
        statuslineCommand = "${pkgs.python3}/bin/python3 ${claudeDir}/statusline.py";
        leanCtx = inputs'.llm-agents.packages.lean-ctx;
        nxopt = pkgs.writeShellApplication {
          name = "nxopt";
          runtimeInputs = [ pkgs.jq ];
          text = ''
            scope=nixos
            if [ "''${1:-}" = "-u" ]; then
              scope=hm
              shift
            fi
            if [ "$#" -lt 1 ]; then
              echo "usage: nxopt [-u] <regex>  (-u = home-manager options)" >&2
              exit 1
            fi
            pattern="$1"
            flake=/etc/nixos
            cache="''${XDG_CACHE_HOME:-$HOME/.cache}/nxopt"
            mkdir -p "$cache"

            if [ "$scope" = hm ]; then
              rev=$(jq -r '."home-manager".rev' "$flake/.tack/pins.lock.json")
              link="$cache/hm-$rev"
              if [ ! -e "$link" ]; then
                echo "nxopt: building home-manager options index for $rev ..." >&2
                find "$cache" -maxdepth 1 -name "hm-*" -delete
                nix build "github:nix-community/home-manager/$rev#docs-json" --out-link "$link" >&2
              fi
              json="$link/share/doc/home-manager/options.json"
            else
              host=$(uname -n)
              key=$({ cat "$flake/.tack/pins.lock.json"; find "$flake/modules" -type f -name '*.nix' -print0 | sort -z | xargs -0 cat; } | sha256sum | cut -d' ' -f1)
              link="$cache/nixos-$host-$key"
              if [ ! -e "$link" ]; then
                echo "nxopt: building nixos options index (config changed) ..." >&2
                find "$cache" -maxdepth 1 -name "nixos-$host-*" -delete
                # shellcheck disable=SC2016
                nix build --impure --no-warn-dirty --out-link "$link" >&2 \
                  --expr '{ host, flake }:
                    let sys = (builtins.getFlake flake).nixosConfigurations.''${host};
                    in (sys.pkgs.nixosOptionsDoc { inherit (sys) options; warningsAreErrors = false; }).optionsJSON' \
                  --argstr host "$host" --argstr flake "$flake"
              fi
              json="$link/share/doc/nixos/options.json"
            fi

            jq -r --arg re "$pattern" '
              to_entries[]
              | select(.key | test($re; "i"))
              | .key + " : " + (.value.type // "?")
                + (if (.value.default.text? // "") != "" then " = " + .value.default.text else "" end)
                + "\n  " + ((.value.description // "") | gsub("\n"; " ") | .[0:200])
            ' "$json"
          '';
        };
      in
      {
        home.packages = [
          inputs'.llm-agents.packages.claude-code
          leanCtx
          nxopt
        ];

        home.file.".claude/rules/agent-workflows.md".source = ./agent-workflows.md;

        home.file.".claude/statusline.py" = {
          executable = true;
          text = ''
            #!${pkgs.python3}/bin/python3
            import json
            import os
            import re
            import sys
            from datetime import datetime, timezone
            from pathlib import Path

            ORANGE = "\033[38;5;172m"
            RESET = "\033[0m"
            MODES = {
                "off",
                "lite",
                "full",
                "ultra",
                "wenyan-lite",
                "wenyan",
                "wenyan-full",
                "wenyan-ultra",
                "commit",
                "review",
                "compress",
            }

            def load_json():
                try:
                    return json.load(sys.stdin)
                except Exception:
                    return {}

            def clean_mode(value):
                return re.sub(r"[^a-z0-9-]", "", value[:64].lower())

            def read_text(path, limit):
                if path.is_symlink() or not path.is_file():
                    return ""
                with path.open("rb") as handle:
                    return handle.read(limit).decode("utf-8", "ignore")

            def caveman_parts(config_dir):
                parts = []
                mode = clean_mode(read_text(config_dir / ".caveman-active", 64).replace("\n", "").replace("\r", ""))
                if mode in MODES:
                    if not mode or mode == "full":
                        parts.append(f"{ORANGE}[CAVEMAN]{RESET}")
                    else:
                        parts.append(f"{ORANGE}[CAVEMAN:{mode.upper()}]{RESET}")

                if os.environ.get("CAVEMAN_STATUSLINE_SAVINGS", "1") != "0":
                    suffix = read_text(config_dir / ".caveman-statusline-suffix", 64)
                    suffix = "".join(ch for ch in suffix if ch >= " " and ch != "\x7f").strip()
                    if suffix:
                        parts.append(f"{ORANGE}{suffix}{RESET}")

                return parts

            def rate_limit_parts(data):
                rate = data.get("rate_limits", {}) if isinstance(data, dict) else {}
                parts = []
                five_hour = rate.get("five_hour", {}) if isinstance(rate.get("five_hour"), dict) else {}
                seven_day = rate.get("seven_day", {}) if isinstance(rate.get("seven_day"), dict) else {}

                five_pct = five_hour.get("used_percentage")
                five_reset = five_hour.get("resets_at")
                if five_pct is not None:
                    label = f"5h: {float(five_pct):.0f}%"
                    if five_reset:
                        t = datetime.fromtimestamp(five_reset, tz=timezone.utc).astimezone()
                        label += f" → {t.strftime('%H:%M')}"
                    parts.append(label)

                seven_pct = seven_day.get("used_percentage")
                seven_reset = seven_day.get("resets_at")
                if seven_pct is not None:
                    label = f"7d: {float(seven_pct):.0f}%"
                    if seven_reset:
                        t = datetime.fromtimestamp(seven_reset, tz=timezone.utc).astimezone()
                        label += f" → {t.strftime('%a %H:%M')}"
                    parts.append(label)
                return parts

            data = load_json()
            config_dir = Path(os.environ.get("CLAUDE_CONFIG_DIR", str(Path.home() / ".claude")))
            parts = caveman_parts(config_dir)
            limits = rate_limit_parts(data)
            if limits:
                parts.append(f"{ORANGE}{' '.join(limits)}{RESET}")
            if parts:
                print(" ".join(parts))
          '';
        };

        home.activation.claudeConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          ${pkgs.coreutils}/bin/mkdir -p "${claudeDir}"
          ${pkgs.coreutils}/bin/install -m 644 ${./claude-global.md} "${claudeDir}/CLAUDE.md"
          ${pkgs.python3}/bin/python3 - <<'PY'
          import json
          import os
          from pathlib import Path

          settings = Path("${claudeDir}") / "settings.json"
          data = json.loads(settings.read_text()) if settings.exists() else {}

          def alive(entry):
              for hook in entry.get("hooks", []):
                  for token in hook.get("command", "").replace('"', " ").split():
                      if token.startswith("/nix/store/") and not os.path.exists(token):
                          return False
              return bool(entry.get("hooks"))

          hooks = data.get("hooks", {})
          for event in list(hooks):
              hooks[event] = [entry for entry in hooks[event] if alive(entry)]
              if not hooks[event]:
                  del hooks[event]

          data["statusLine"] = {
              "type": "command",
              "command": "${statuslineCommand}",
              "refreshInterval": 30,
          }
          data.setdefault("cleanupPeriodDays", 30)

          settings.write_text(json.dumps(data, indent=2) + "\n")

          claude_json = Path("${config.home.homeDirectory}/.claude.json")
          state = json.loads(claude_json.read_text()) if claude_json.exists() else {}
          servers = state.setdefault("mcpServers", {})
          servers.pop("nixos", None)
          servers.pop("gitnexus", None)
          servers["lean-ctx"] = {
              "type": "stdio",
              "command": "${leanCtx}/bin/lean-ctx",
              "args": [],
              "env": {
                  "LEAN_CTX_DATA_DIR": "${config.xdg.configHome}/lean-ctx",
                  "LEAN_CTX_ALLOW_PATH": "${config.home.homeDirectory}:/persist${config.home.homeDirectory}:/nix/store:/tmp",
              },
          }
          claude_json.write_text(json.dumps(state, indent=2) + "\n")
          PY
        '';
      };

    persistUser =
      { hmConfig, ... }:
      {
        directories = [
          {
            directory = ".claude";
            how = "symlink";
          }
          {
            directory = "${hmConfig.xdg.cacheHome}/claude-cli-nodejs";
            how = "symlink";
          }
        ];
        files = [
          {
            file = ".claude.json";
            how = "symlink";
          }
        ];
      };
  };
}
