{ den, lib, ... }:
{
  den.aspects._host-info-emit = {
    host-info =
      { host, ... }:
      lib.optional (host.ip != null && host.publicKey != null) {
        inherit (host) name ip publicKey;
      };
  };

  den.policies.collect-host-info =
    { host, ... }:
    let
      inherit (den.lib.policy) pipe;
    in
    [
      (pipe.from den.quirks.host-info [
        (pipe.collect ({ host, ... }: true))
      ])
    ];

  den.default.includes = [ den.policies.collect-host-info ];

  den.schema.host.includes = [ den.aspects._host-info-emit ];
}
