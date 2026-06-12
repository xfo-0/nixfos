{ den, ... }:
let
  inherit (den.lib.policy) pipe;
in
{
  den.quirks.binary-caches.description = "Binary-cache records { url, publicKey, kind } emitted by cache services (kind = ncps/harmonia) and external-cache aspects (kind = external); collected at host scope for ncro, ncps and harmonia-client consumers.";

  den.policies.collect-binary-caches =
    { host, ... }:
    [
      (pipe.from den.quirks.binary-caches [
        (pipe.collect ({ host, ... }: true))
      ])
    ];

  den.default.includes = [ den.policies.collect-binary-caches ];
}
