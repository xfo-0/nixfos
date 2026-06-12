{ ... }:
{
  den.batteries.nixos-config-link =
    path:
    { host, ... }:
    {
      name = "nixos-config-link(${path}@${host.name})";
      homeManager =
        { config, ... }:
        {
          home.file."${path}".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos";
        };
    };
}
