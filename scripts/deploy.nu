#!/usr/bin/env nu

# Reinstall a host via nixos-anywhere over LAN, preserving its declarative ssh
# identity. Run from a controller that has this repo checked out, against the
# target booted into the installer ISO.
#
# Disk by-id and facter are prepared in the host config beforehand (e.g. on the
# live editable config); this script does not touch hardware detection.
#
#   nu scripts/deploy.nu AO05 root@192.168.12.50

def main [
  host: string        # flake host attr, e.g. AO05
  target: string      # ssh destination of the target-in-installer, e.g. root@192.168.12.50
] {
  let keyfile = $".secrets/hosts/($host)/ssh_host_ed25519_key"
  if not ($keyfile | path exists) {
    error make { msg: $"no sops host key at ($keyfile) — capture it first" }
  }

  for tool in [sops ssh-to-age nixos-anywhere ssh-keygen] {
    if (which $tool | is-empty) {
      error make { msg: $"($tool) not on PATH — must be locally available \(sops/ssh-to-age via sops-infra; nixos-anywhere via deploy tooling)" }
    }
  }

  let agekey = (^ssh-to-age -private-key -i $"($env.HOME)/.ssh/id_ed25519" | str trim)

  let tree = (^mktemp -d | str trim)
  mkdir $"($tree)/persist/etc/ssh"

  with-env { SOPS_AGE_KEY: $agekey } {
    ^sops decrypt --input-type binary --output-type binary $keyfile
      | save -f $"($tree)/persist/etc/ssh/ssh_host_ed25519_key"
  }
  chmod 600 $"($tree)/persist/etc/ssh/ssh_host_ed25519_key"

  ^ssh-keygen -y -f $"($tree)/persist/etc/ssh/ssh_host_ed25519_key"
    | save -f $"($tree)/persist/etc/ssh/ssh_host_ed25519_key.pub"

  print $"extra-files tree:(char nl)"
  ^find $tree -type f | print

  print $"(char nl)deploying .#($host) -> ($target) ..."
  ^nixos-anywhere --flake $".#($host)" --extra-files $tree $target

  rm -rf $tree

  print $"(char nl)verify: ssh ($host) 'systemctl --failed'"
}
