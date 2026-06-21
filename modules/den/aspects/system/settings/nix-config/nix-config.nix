{ den, inputs, ... }:
{
  flake-file.inputs.nix-src.url = "gh:DeterminateSystems/nix-src";

  den.schema.host.includes = [ den.aspects.nix-config.core-config ];

  den.aspects.nix-config = {
    includes = [
      den.aspects.nix-config.garbage-collection
      den.aspects.nix-config.locale
    ];

    core-config = {
      nixos =
        { lib, pkgs, ... }:
        {
          nix.package = inputs.nix-src.packages.${pkgs.stdenv.hostPlatform.system}.default;

          nix.checkConfig = false;
          nix.settings = {
            experimental-features = [
              "nix-command"
              "flakes"
              "parallel-eval"
            ];
            trusted-users = lib.mkForce [
              "root"
              "@wheel"
            ];
            lazy-trees = true;
            eval-cores = 0;
            max-jobs = "auto";
          };

          nix.channel.enable = false;
          nix.registry.nixpkgs.flake = inputs.nixpkgs;
          nix.settings.nix-path = lib.mkForce [ "nixpkgs=flake:nixpkgs" ];

          documentation.nixos.enable = lib.mkDefault false;

          programs.nix-ld.enable = lib.mkDefault true;

          system.stateVersion = lib.mkDefault "25.11";

          security = {
            sudo.enable = false;
            sudo-rs = {
              enable = true;
              wheelNeedsPassword = lib.mkDefault false;
            };
          };
          users.mutableUsers = lib.mkDefault false;
        };
    };

    garbage-collection = {
      nixos =
        { lib, ... }:
        {
          nix.gc = {
            automatic = lib.mkDefault true;
            dates = lib.mkDefault "weekly";
            options = lib.mkDefault "--delete-older-than 30d";
          };
          nix.settings.auto-optimise-store = lib.mkDefault true;
        };
    };

    locale = {
      nixos =
        { lib, host, ... }:
        {
          time.timeZone = lib.mkDefault (host.settings.core.timezone or "UTC");
          i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
          console.keyMap = lib.mkDefault "us";
        };
    };
  };
}
