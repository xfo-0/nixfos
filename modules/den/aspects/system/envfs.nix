{ den, ... }:
{
  den.aspects.envfs.nixos = {
    services.envfs.enable = true;
  };

  den.schema.host.includes = [ den.aspects.envfs ];
}
