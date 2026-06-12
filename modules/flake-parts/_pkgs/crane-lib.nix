# Shared crane library with static.crates.io registry mirror.
#
# The crates.io API sometimes returns 403 errors. This module configures
# crane to use the static.crates.io mirror instead, replacing the need
# for the patched importCargoLock in import-cargo-lock-patched.nix.
#
# Usage in package definitions:
#   { pkgs, inputs, ... }:
#   let craneLib = import ./crane-lib.nix { inherit pkgs inputs; };
#   in craneLib.buildPackage { src = craneLib.cleanCargoSource ./.; ... }

{
  pkgs,
  inputs,
}:

let
  craneLib = inputs.crane.mkLib pkgs;
in
craneLib.appendCrateRegistries [
  (craneLib.registryFromDownloadUrl {
    dl = "https://static.crates.io/crates";
    indexUrl = "https://github.com/rust-lang/crates.io-index";
  })
]
