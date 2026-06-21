{ ... }:
{
  den.aspects.nixos-config-sync = {
    nixos =
      {
        host,
        config,
        pkgs,
        lib,
        ...
      }:
      let
        user = host.primaryUser or null;
        home = if user != null then config.users.users.${user}.home else null;
      in
      lib.mkIf (home != null) {
        system.activationScripts.syncEtcNixos = {
          deps = [ "users" ];
          text = ''
            src=${home}/nx
            dst=/etc/nixos
            if [ -d "$src" ] && [ ! -L "$src" ] \
              && [ "$(${pkgs.coreutils}/bin/readlink -f "$src")" != "$(${pkgs.coreutils}/bin/readlink -f "$dst")" ]; then
              ${pkgs.rsync}/bin/rsync -a --delete --delete-excluded \
                --chown=root:wheel \
                --exclude='.git/' \
                --exclude='.jj/' \
                --exclude='.direnv/' \
                --exclude='result' \
                --exclude='.Trash-1000/' \
                "$src"/ "$dst"/ \
              || echo "nixos-config-sync: rsync ~/nx -> /etc/nixos failed" >&2
            fi
          '';
        };
      };
  };
}
