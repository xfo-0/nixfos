{ den, ... }:
{
  den.aspects.pickers = {
    homeManager =
      { pkgs, ... }:
      let
        term-pick = pkgs.writeShellApplication {
          name = "term-pick";
          runtimeInputs = [
            pkgs.foot
            pkgs.television
          ];
          text = ''
            input=$(mktemp -t term-pick.XXXXXX)
            output=$(mktemp -t term-pick-out.XXXXXX)
            trap 'rm -f "$input" "$output"' EXIT

            cat > "$input"
            grep -q '[^[:space:]]' "$input" || exit 1

            if ! systemctl --user is-active -q foot.service; then
              systemctl --user start foot.service || true
              sock="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/foot-''${WAYLAND_DISPLAY:-wayland-1}.sock"
              for _ in $(seq 1 40); do
                [ -S "$sock" ] && break
                sleep 0.05
              done
            fi

            footclient --app-id=term_picker -- sh -c \
              "tv --no-preview --no-remote --no-help-panel --no-status-bar $* < $input > $output" \
              || true

            result=$(cat "$output" 2>/dev/null || true)
            [ -n "$result" ] || exit 1
            printf '%s' "$result"
          '';
        };

        rbw-pick = pkgs.writeShellApplication {
          name = "rbw-pick";
          runtimeInputs = [
            pkgs.rbw
            pkgs.wl-clipboard
            pkgs.cliphist
            pkgs.libnotify
            term-pick
          ];
          text = ''
            mode="''${1:-pass}"
            tab=$(printf '\t')
            sel=$(rbw ls --fields name,user | term-pick) || exit 1
            name=''${sel%%"$tab"*}
            user=''${sel#*"$tab"}
            [ "$user" = "$sel" ] && user=""

            set -- "$name"
            [ -n "$user" ] && set -- "$name" "$user"

            case "$mode" in
              pass) secret=$(rbw get "$@") ;;
              code) secret=$(rbw code "$@") ;;
              user) secret=$user ;;
              *)
                echo "usage: rbw-pick [pass|code|user]" >&2
                exit 1
                ;;
            esac
            [ -n "$secret" ] || exit 1

            printf '%s' "$secret" | wl-copy
            sleep 0.4
            cliphist list 2>/dev/null | head -1 | cliphist delete 2>/dev/null || true
            notify-send -t 4000 "rbw" "$mode for $name copied, clears in 45s"
            ( sleep 45 && wl-copy --clear ) &
          '';
        };

        niri-focus = pkgs.writers.writeNuBin "niri-focus" (builtins.readFile ./niri-focus.nu);

        desktop-launch = pkgs.writers.writeNuBin "desktop-launch" (builtins.readFile ./desktop-launch.nu);
      in
      {
        home.packages = [
          term-pick
          rbw-pick
          niri-focus
          desktop-launch
        ];

        programs.foot = {
          enable = true;
          server.enable = true;
        };
      };
  };

  den.aspects.niri.includes = [ den.aspects.pickers ];
}
