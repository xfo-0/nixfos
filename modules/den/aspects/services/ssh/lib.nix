{
  den.aspects.lib.ssh = {
    authorizedKeys =
      { user, ... }:
      {
        nixos.users.users.${user.userName} = {
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINI1yeAdQ0qqHOr/Xt/Bz3ZXmPPDOEIn+hLWxX4iyHct xfo"
          ];
        };
        persistIgnore.directories = [ "/etc/ssh/authorized_keys.d" ];
      };
  };
}
