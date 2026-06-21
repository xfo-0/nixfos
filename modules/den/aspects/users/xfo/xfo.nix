{
  config,
  den,
  __findFile,
  inputs,
  ...
}:
let
  secretFile = "${config.den.secretsConfig.root}/users/xfo/secrets.yaml";
in
{
  den.aspects.xfo = {
    includes = [
      <den/primary-user>
      <den/host-aspects>
      <shader-cache>
    ]
    ++ (with den.aspects; [
      roles.desktop
      nvim
      noctalia
      scripts-user
      rmpc
      taskwarrior
      xdg-termfilechooser
    ]);

    user =
      { config, ... }:
      {
        hashedPasswordFile = config.sops.secrets.user-password.path or null;
      };

    nixos = {
      imports = [ inputs.sops-nix.nixosModules.sops ];
      sops.defaultSopsFile = secretFile;
      sops.secrets.user-password.neededForUsers = true;
      sops.secrets."ssh/id_ed25519" = {
        owner = "xfo";
        group = "users";
        mode = "0600";
      };
    };

    homeManager =
      { config, lib, ... }:
      {
        imports = [ inputs.sops-nix.homeManagerModules.sops ];
        sops.defaultSopsFile = secretFile;
        sops.age.sshKeyPaths = lib.mkDefault [ "/run/secrets/ssh/id_ed25519" ];
        home.file.".ssh/id_ed25519".source =
          config.lib.file.mkOutOfStoreSymlink "/run/secrets/ssh/id_ed25519";
        manual.manpages.enable = lib.mkDefault false;
      };
  };
}
