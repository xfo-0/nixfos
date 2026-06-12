{ den, inputs, ... }:
{
  flake-file.inputs.preservation.url = "gh:nix-community/preservation";

  den.aspects.persist = {
    includes = [
      den.aspects.persist._.class
      den.aspects.persist._.find-ephemeral
      den.aspects.persist._.minimal
    ];

    nixos =
      { lib, ... }:
      {
        imports = [ inputs.preservation.nixosModules.preservation ];
        preservation.enable = lib.mkDefault true;
      };
  };
}
