{
  den.aspects.persist._.replicated.nixos =
    { config, lib, ... }:
    {
      options.hostConfig.replication = with lib.types; {
        directories = lib.mkOption {
          type = listOf anything;
          default = [ ];
        };
        files = lib.mkOption {
          type = listOf anything;
          default = [ ];
        };
      };

      config.preservation.preserveAt."/persist" = {
        inherit (config.hostConfig.replication) directories files;
      };
    };
}
