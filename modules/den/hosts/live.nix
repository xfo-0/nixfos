{
  __findFile,
  den,
  inputs,
  ...
}:
{
  den.hosts.x86_64-linux.live = {
    environment = "live";
    primaryUser = "xfo";
    settings = {
      capabilities.graphical.enable = true;
    };
  };

  den.aspects.live = {
    includes = with den.aspects; [
      capabilities.graphical
      <desktop-type/window-manager/niri>
    ];

    nixos =
      {
        pkgs,
        lib,
        config,
        modulesPath,
        ...
      }:
      let
        niriSession = "${config.programs.niri.package}/bin/niri-session";
      in
      {
        imports = [
          "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
          inputs.home-manager.nixosModules.home-manager
        ];

        nix.settings.experimental-features = [
          "nix-command"
          "flakes"
        ];

        services.getty.autologinUser = lib.mkForce null;
        services.greetd = {
          enable = true;
          settings = {
            terminal.vt = 1;
            default_session = {
              user = "greeter";
              command = "${pkgs.greetd}/bin/agreety --cmd ${niriSession}";
            };
            initial_session = {
              user = "xfo";
              command = niriSession;
            };
          };
        };

        services.openssh = {
          enable = lib.mkForce true;
          openFirewall = lib.mkForce true;
          settings.PermitRootLogin = lib.mkForce "prohibit-password";
        };
        users.users.root.openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINI1yeAdQ0qqHOr/Xt/Bz3ZXmPPDOEIn+hLWxX4iyHct xfo"
        ];

        system.stateVersion = lib.mkForce "26.05";
        boot.supportedFilesystems.zfs = lib.mkForce false;
        xdg.mime.enable = lib.mkForce true;
        xdg.icons.enable = lib.mkForce true;
        xdg.sounds.enable = lib.mkForce true;
        xdg.menus.enable = lib.mkForce true;
        xdg.autostart.enable = lib.mkForce true;

        environment.systemPackages = with pkgs; [
          git
          vim
          nixos-facter
          disko
          nixos-anywhere
          parted
          gptfdisk
          dosfstools
          e2fsprogs
          btrfs-progs
          xfsprogs
          cryptsetup
          ddrescue
          testdisk
          smartmontools
          nvme-cli
          rsync
          restic
          dust
          duf
          dysk
          ncdu
          ripgrep
          fd
          curl
          tmux
        ];

        environment.etc."nixos".source = lib.cleanSourceWith {
          name = "nixfos-flake";
          src = inputs.self;
          filter = path: _type: !(lib.hasInfix "/.secrets" path);
        };
      };
  };
}
