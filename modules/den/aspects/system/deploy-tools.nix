{ den, ... }:
{
  den.schema.host.includes = [ den.aspects.deploy-tools ];

  den.aspects.deploy-tools = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = [ pkgs.nixos-anywhere ];
      };
  };
}
