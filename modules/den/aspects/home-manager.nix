{ den, lib, ... }:
{
  den.schema = {
    host.includes = [ den.aspects.home-manager.nixConfig ];
    user.includes = [ den.aspects.home-manager.hmConfig ];
  };

  den.aspects.home-manager = {
    nixConfig = {
      nixos.home-manager = {
        useUserPackages = lib.mkDefault true;
        useGlobalPkgs = lib.mkDefault true;
        backupFileExtension = lib.mkDefault "backup";
        overwriteBackup = lib.mkDefault true;
        sharedModules = [
          {
            nixpkgs.config = lib.mkForce null;
            nixpkgs.overlays = lib.mkForce null;
          }
        ];
      };
    };

    hmConfig = {
      homeManager =
        { lib, ... }:
        {
          home.stateVersion = lib.mkDefault "25.11";

          # home-manager's activation runs `nix-env -q`, which recreates dangling
          # legacy-profile/channel compat symlinks; channels are disabled and the
          # user profile is flakes-only, so prune them after each activation.
          home.activation.pruneNixCompatLinks = lib.hm.dag.entryAfter [ "installPackages" ] ''
            run rm -f "$HOME/.nix-profile" "$HOME/.nix-defexpr/channels" "$HOME/.nix-defexpr/channels_root"
            run rmdir "$HOME/.nix-defexpr" 2>/dev/null || true
          '';
        };
    };
  };
}
