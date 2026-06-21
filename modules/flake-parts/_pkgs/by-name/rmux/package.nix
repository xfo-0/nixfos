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
  pname = "rmux";
  version = "0.3.1";

  src = inputs.src-rmux;

  cargoLock = "${src}/Cargo.lock";

  doCheck = false;

  postInstall = ''
    ln -s $out/bin/rmux $out/bin/tmux
  '';

  meta = with lib; {
    description = "Terminal multiplexer with tmux-style CLI, daemon runtime, Rust SDK, and ratatui integration";
    homepage = "https://github.com/helvesec/rmux";
    license = with licenses; [
      mit
      asl20
    ];
    mainProgram = "rmux";
    platforms = platforms.unix;
  };
}
