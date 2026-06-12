{ lib, ... }:
{
  den.aspects.wake-client = {
    settings = {
      options.broadcast = lib.mkOption {
        type = lib.types.str;
        default = "255.255.255.255";
        description = "Broadcast address for wake magic packets. Set per-subnet (e.g. 192.168.12.255) if your router doesn't forward the global broadcast.";
      };
    };

    nixos =
      {
        host,
        wake-targets,
        lib,
        pkgs,
        ...
      }:
      let
        cfg = host.settings.network.wake-client or { };
        broadcast = cfg.broadcast or "255.255.255.255";
        wakeable = lib.filter (t: (t.mac or null) != null) wake-targets;
        cases = lib.concatMapStringsSep "\n" (t: ''
          ${t.name})
            wakeonlan -i ${lib.escapeShellArg broadcast} ${lib.escapeShellArg t.mac}
            echo "wake: sent magic packet to ${t.name} (${t.mac}) via ${broadcast}"
            ;;'') wakeable;
        known = lib.concatMapStringsSep " " (t: t.name) wakeable;
        wakeScript = pkgs.writeShellApplication {
          name = "wake";
          runtimeInputs = [ pkgs.wakeonlan ];
          text = ''
            if [ $# -lt 1 ]; then
              echo "usage: wake <hostname>"
              echo "known hosts: ${known}"
              exit 1
            fi
            case "$1" in
            ${cases}
              *)
                echo "wake: unknown host '$1'"
                echo "known: ${known}"
                exit 2
                ;;
            esac
          '';
        };
      in
      {
        environment.systemPackages = [ wakeScript ];
      };
  };
}
