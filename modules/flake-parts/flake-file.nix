{ inputs, config, ... }:
{
  imports = [ inputs.flake-file.flakeModules.tack ];

  flake-file = {
    tack = {
      package = pkgs: inputs.tack.packages.${pkgs.stdenv.hostPlatform.system}.default;
      recomposable = true;
      shorturls.gh = "github:{path}";
      allFollow.nixpkgs = [ "nixpkgs-lib" ];
    };

    inputs = {
      flake-file.url = "gh:denful/flake-file";
      nixpkgs.url = "gh:NixOS/nixpkgs/nixos-unstable";
      tack = {
        url = "gh:manic-systems/tack";
        clone = {
          enable = true;
          tags = [ "den" "infra" ];
        };
      };
      flake-parts.url = "gh:hercules-ci/flake-parts";
      pkgs-by-name-for-flake-parts.url = "gh:drupol/pkgs-by-name-for-flake-parts";
      import-tree = {
        url = "gh:denful/import-tree";
        clone = {
          enable = true;
          tags = [ "den" ];
        };
      };
      den.url = "gh:sini/den/688478b9d9597088beb28b0f39d55f7d31744a07";
      nh.url = "gh:xfo-0/nh/b7bd1a7d9a6ecd7bf348d4cde63102e93c29a44f";
      gen-algebra.url = "gh:sini/gen-algebra/49f6721bd314b38272bd6b1b26139569365c85a6";
      gen-schema.url = "gh:sini/gen-schema/c072f76be4164a854312b892867c2d007891575a";
      scope-engine.url = "gh:sini/scope-engine/7e301a5b0372a554ad1f57b080a9a8918f483ff8";
      home-manager.url = "gh:nix-community/home-manager";
    };
  };

  perSystem =
    { pkgs, lib, ... }:
    let
      withGithubToken =
        name: app:
        pkgs.writeShellApplication {
          inherit name;
          text = ''
            if [ -r /run/secrets/github/token ]; then
              GITHUB_TOKEN="$(cat /run/secrets/github/token)"
              export GITHUB_TOKEN
            fi
            exec ${lib.getExe app} "$@"
          '';
        };
    in
    {
      packages.write-tack = withGithubToken "write-tack" (config.flake-file.apps.write-tack pkgs);
      packages.write-lock = withGithubToken "write-lock" (config.flake-file.apps.write-lock pkgs);
    };
}
