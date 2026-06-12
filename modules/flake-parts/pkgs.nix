{ inputs, withSystem, ... }:

let
  localPackagesOverlay =
    _final: prev:
    withSystem prev.stdenv.hostPlatform.system (
      { config, ... }:
      {
        local = config.legacyPackages;
      }
    );
in
{
  flake-file.inputs = {
    crane.url = "gh:ipetkov/crane";
  };

  imports = [ inputs.pkgs-by-name-for-flake-parts.flakeModule ];

  perSystem.pkgsDirectory = ./_pkgs/by-name;

  flake.overlays.default = localPackagesOverlay;

  den.aspects.pkgs-cfg.nixos.nixpkgs.overlays = [
    localPackagesOverlay

    # mbrola-voices is ~650MB — disable unless explicitly needed by speechd users
    (final: prev: {
      espeak-ng = prev.espeak-ng.override { mbrolaSupport = false; };
    })
  ];
}
