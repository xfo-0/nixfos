# Minimal installer ISO with SSH + flakes
# Build: nix build .#nixosConfigurations.installer.config.system.build.isoImage
{ den, ... }:
{
  den.hosts.x86_64-linux.installer = { };

  den.aspects.installer = {
    nixos =
      {
        pkgs,
        lib,
        modulesPath,
        ...
      }:
      {
        imports = [ "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix" ];

        nix.settings.experimental-features = [
          "nix-command"
          "flakes"
        ];

        services.openssh = {
          enable = lib.mkForce true;
          openFirewall = lib.mkForce true;
          settings.PermitRootLogin = lib.mkForce "prohibit-password";
        };
        users.users.root.openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINI1yeAdQ0qqHOr/Xt/Bz3ZXmPPDOEIn+hLWxX4iyHct xfo"
        ];

        services.getty.autologinUser = lib.mkForce "root";

        environment.systemPackages = with pkgs; [
          git
          vim
          nixos-facter
        ];

        system.stateVersion = lib.mkForce "26.05";
        boot.supportedFilesystems.zfs = lib.mkForce false;

        services.getty.helpLine = lib.mkForce ''
          === NixOS Installer ===
          Deploy: nixos-anywhere --flake .#HOST --extra-files .secrets/hosts/HOST root@THIS-IP
        '';
      };
  };
}
