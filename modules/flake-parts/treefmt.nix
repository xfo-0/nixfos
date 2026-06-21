{ inputs, ... }:
{
  flake-file.inputs.treefmt-nix.url = "gh:numtide/treefmt-nix";

  imports = [ inputs.treefmt-nix.flakeModule ];

  perSystem =
    { ... }:
    {
      treefmt = {
        projectRoot = inputs.self;
        projectRootFile = "flake.nix";
        programs.nixfmt.enable = true;
        settings.excludes = [ ".secrets/**" ];
      };
    };
}
