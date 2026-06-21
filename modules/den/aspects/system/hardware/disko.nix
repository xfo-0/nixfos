{ inputs, ... }:
{
  flake-file.inputs.disko.url = "gh:nix-community/disko";

  den.aspects.disko = diskoPath: {
    nixos.imports = [
      inputs.disko.nixosModules.disko
      diskoPath
    ];
  };
}
