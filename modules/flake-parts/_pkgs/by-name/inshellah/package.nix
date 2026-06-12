{
  pkgs,
  inputs,
  lib ? pkgs.lib,
  ...
}:

let
  craneLib = import ../../crane-lib.nix { inherit pkgs inputs; };
in

craneLib.buildPackage rec {
  pname = "inshellah";
  version = "0.1.1";

  src = inputs.inshellah;

  cargoLock = "${src}/Cargo.lock";

  meta = {
    description = "nushell completion indexer";
    mainProgram = "inshellah";
  };
}
