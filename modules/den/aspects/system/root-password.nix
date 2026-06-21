{ config, den, ... }:
let
  rootPwFile = "${config.den.secretsConfig.root}/common/root-password.yaml";
in
{
  den.schema.host.includes = [ den.aspects.root-password ];

  den.aspects.root-password = {
    nixos =
      { config, ... }:
      {
        sops.secrets.root-password = {
          sopsFile = rootPwFile;
          neededForUsers = true;
        };
        users.users.root.hashedPasswordFile = config.sops.secrets.root-password.path;
      };
  };
}
