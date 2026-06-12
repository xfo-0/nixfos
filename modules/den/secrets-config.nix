{ lib, inputs, ... }:
{
  options.den.secretsConfig = {
    root = lib.mkOption {
      type = lib.types.path;
      default = "${inputs.self}/.secrets";
      description = "Root path for encrypted secret files.";
    };

    masterIdentities = lib.mkOption {
      type = lib.types.listOf lib.types.path;
      default = [ ];
      description = "Age master identity public key paths for agenix-rekey.";
    };
  };
}
