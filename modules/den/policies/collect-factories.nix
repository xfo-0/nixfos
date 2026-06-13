{ den, ... }:
let
  inherit (den.lib.policy) pipe;
in
{
  _module.args.collectors.collectAllHosts =
    name:
    { host, ... }:
    [
      (pipe.from name [
        (pipe.collect ({ host, ... }: true))
      ])
    ];
}
