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
        codebaseMemory = pkgs.stdenvNoCC.mkDerivation rec {
          pname = "codebase-memory-mcp";
          version = "0.8.1";
          src = pkgs.fetchurl {
            url = "https://github.com/DeusData/codebase-memory-mcp/releases/download/v${version}/codebase-memory-mcp-linux-amd64-portable.tar.gz";
            hash = "sha256-arh6bAXQSd3ldwCAPKCrQZn88llzoGBmGK8Pzuc/Wr0=";
          };
          sourceRoot = ".";
          dontConfigure = true;
          dontBuild = true;
          dontStrip = true;
          installPhase = ''
            runHook preInstall
            install -Dm755 codebase-memory-mcp $out/bin/codebase-memory-mcp
            runHook postInstall
          '';
          meta.platforms = [ "x86_64-linux" ];
        };
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
            flake="$HOME/nx"
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
        denContextHook = pkgs.writeShellApplication {
          name = "den-context-hook";
          runtimeInputs = [ pkgs.jq ];
          text = ''
            input="$(cat)"
            cwd="$(printf '%s' "$input" | jq -r '.cwd // empty')"
            [ -z "$cwd" ] && cwd="$PWD"
            traits=()
            [ -d "$cwd/.jj" ] && traits+=("jj-managed")
            [ -e "$cwd/flake.nix" ] && traits+=("nix-flake")
            [ -d "$cwd/.beads" ] && traits+=("beads-tracked")
            [ "''${#traits[@]}" -eq 0 ] && exit 0
            joined="$(printf '%s, ' "''${traits[@]}")"
            joined="''${joined%, }"
            line="Repo context (detected): $joined — your CLAUDE.md rules for these apply."
            if [ -e "$cwd/flake.nix" ] || [ -d "$cwd/.jj" ]; then
              line="$line Related repos are moor-tracked: \`moor ls <tag>\` then --add-dir to bridge them."
            fi
            jq -nc --arg c "$line" '{hookSpecificOutput:{hookEventName:"SessionStart",additionalContext:$c}}'
          '';
        };
        herdrAgentStateHook = pkgs.writeShellScript "herdr-agent-state.sh" ''
          export PATH=${pkgs.python3}/bin''${PATH:+:$PATH}
          exec ${pkgs.runtimeShell} ${./herdr-agent-state.sh} "$@"
        '';
      in
      {
        home.packages = [
          inputs'.llm-agents.packages.claude-code
          leanCtx
          codebaseMemory
          nxopt
        ];

        home.file.".claude/statusline.py" = {
          executable = true;
          text = ''
            #!${pkgs.python3}/bin/python3
            import json
            import sys
            from datetime import datetime, timezone

            ORANGE = "\033[38;5;172m"
            RESET = "\033[0m"

            def load_json():
                try:
                    return json.load(sys.stdin)
                except Exception:
                    return {}

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
            parts = []
            limits = rate_limit_parts(data)
            if limits:
                parts.append(f"{ORANGE}{' '.join(limits)}{RESET}")
            if parts:
                print(" ".join(parts))
          '';
        };

        home.activation.claudeConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          ${pkgs.coreutils}/bin/mkdir -p "${claudeDir}"
          ${pkgs.python3}/bin/python3 - <<'PY'
          import json
          import os
          from pathlib import Path

          settings = Path("${claudeDir}") / "settings.json"
          if settings.exists():
              try:
                  data = json.loads(settings.read_text())
              except json.JSONDecodeError as err:
                  print(f"claudeConfig: leaving unparseable {settings} untouched: {err}")
                  raise SystemExit(0)
          else:
              data = {}

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

          session_start = data.setdefault("hooks", {}).setdefault("SessionStart", [])
          session_start = [e for e in session_start if "den-context-hook" not in json.dumps(e)]
          session_start.append({"hooks": [{"type": "command", "command": "${denContextHook}/bin/den-context-hook"}]})
          data["hooks"]["SessionStart"] = session_start

          session_start = [e for e in data["hooks"]["SessionStart"] if "herdr-agent-state" not in json.dumps(e)]
          session_start.append({"matcher": "*", "hooks": [{"type": "command", "command": "${herdrAgentStateHook} session", "timeout": 10}]})
          data["hooks"]["SessionStart"] = session_start

          data["statusLine"] = {
              "type": "command",
              "command": "${statuslineCommand}",
              "refreshInterval": 30,
          }
          data.setdefault("cleanupPeriodDays", 30)

          settings.write_text(json.dumps(data, indent=2) + "\n")

          claude_json = Path("${config.home.homeDirectory}/.claude.json")
          if claude_json.exists():
              try:
                  state = json.loads(claude_json.read_text())
              except json.JSONDecodeError as err:
                  print(f"claudeConfig: leaving unparseable {claude_json} untouched: {err}")
                  raise SystemExit(0)
          else:
              state = {}
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
          servers["codebase-memory-mcp"] = {
              "type": "stdio",
              "command": "${codebaseMemory}/bin/codebase-memory-mcp",
              "args": [],
              "env": {
                  "CBM_CACHE_DIR": "${config.xdg.cacheHome}/codebase-memory-mcp",
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
          {
            directory = "${hmConfig.xdg.cacheHome}/codebase-memory-mcp";
            how = "symlink";
          }
          {
            directory = "${hmConfig.xdg.dataHome}/den-graph";
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
