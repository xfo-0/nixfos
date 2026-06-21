{ den, ... }:
{
  den.aspects.intel-dgpu.nixos =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      gated = config.hardware.facter.enable;
      cards = config.hardware.facter.report.hardware.graphics_card or [ ];
      hasArc = lib.any (c: builtins.elem "xe" (c.driver_modules or [ ])) cards;

      dgpu = pkgs.writeShellApplication {
        name = "dgpu";
        runtimeInputs = with pkgs; [
          pciutils
          coreutils
          psmisc
        ];
        text = ''
          dev=
          for d in /sys/bus/pci/drivers/xe/0000:*; do
            [ -e "$d" ] && { dev=$d; break; }
          done
          if [ -z "''${dev:-}" ]; then
            echo "no xe (Arc) device bound" >&2
            exit 1
          fi
          addr=$(basename "$dev")
          rnode="/dev/dri/by-path/pci-$addr-render"

          reexec_root() {
            if [ "$(id -u)" -ne 0 ]; then exec sudo "$0" "$@"; fi
          }

          case "''${1:-status}" in
            status)
              echo "card    : $addr ($(lspci -s "$addr" | cut -d' ' -f2-))"
              echo "power   : control=$(cat "$dev/power/control") runtime=$(cat "$dev/power/runtime_status")"
              echo "state   : $(cat "$dev/power_state" 2>/dev/null || echo '?') (D3cold≈0W, D3hot≈few W, D0=on)"
              echo "d3cold  : allowed=$(cat "$dev/d3cold_allowed" 2>/dev/null || echo '?')"
              if [ -r "$dev/power/runtime_suspended_time" ]; then
                echo "idle_ms : $(cat "$dev/power/runtime_suspended_time")"
              fi
              if [ -e "$rnode" ]; then
                holders=$(fuser "$rnode" 2>/dev/null || true)
                echo "render  : $rnode''${holders:+ held by$holders}"
              fi
              ;;
            on)
              reexec_root "$@"
              echo on > "$dev/power/control"
              echo "B580 pinned awake (power/control=on)"
              ;;
            off | auto)
              reexec_root "$@"
              echo auto > "$dev/power/control"
              echo "B580 released to deep idle (power/control=auto)"
              ;;
            *)
              echo "usage: dgpu [status|on|off]" >&2
              exit 2
              ;;
          esac
        '';
      };
    in
    lib.mkIf (gated && hasArc) {
      services.udev.extraRules = ''
        ACTION=="bind", SUBSYSTEM=="pci", DRIVER=="xe", ATTR{d3cold_allowed}="1", ATTR{power/control}="auto"
      '';

      environment.systemPackages = [ dgpu ];
    };

  den.schema.host.includes = [ den.aspects.intel-dgpu ];
}
