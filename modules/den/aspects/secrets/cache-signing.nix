{ lib, ... }:
{
  den.aspects.secrets.cache-signing = {
    settings = {
      options.harmoniaSecretKey = lib.mkOption {
        type = lib.types.str;
        default = "cache-signing/harmonia";
        description = "sops secret name for harmonia ed25519 signing key.";
      };
      options.ncpsSecretKey = lib.mkOption {
        type = lib.types.str;
        default = "cache-signing/ncps";
        description = "sops secret name for ncps ed25519 signing key.";
      };
    };

    nixos =
      {
        host,
        config,
        ...
      }:
      let
        cfg = host.settings.secrets.cache-signing or { };
        secretRoot = host.secretPath or null;
        sopsFile = if secretRoot == null then null else "${secretRoot}/cache-signing.yaml";
        harmoniaKey = cfg.harmoniaSecretKey or "cache-signing/harmonia";
        ncpsKey = cfg.ncpsSecretKey or "cache-signing/ncps";
      in
      lib.mkIf (sopsFile != null) {
        sops.secrets = lib.mkMerge [
          (lib.mkIf (config.services.harmonia.cache.enable or false) {
            ${harmoniaKey}.sopsFile = sopsFile;
          })
          (lib.mkIf (config.services.ncps.enable or false) {
            ${ncpsKey}.sopsFile = sopsFile;
          })
        ];

        services.harmonia.cache.signKeyPaths = lib.mkIf (config.services.harmonia.cache.enable or false) [
          config.sops.secrets.${harmoniaKey}.path
        ];

        services.ncps.cache.secretKeyPath = lib.mkIf (config.services.ncps.enable or false
        ) config.sops.secrets.${ncpsKey}.path;
      };
  };
}
