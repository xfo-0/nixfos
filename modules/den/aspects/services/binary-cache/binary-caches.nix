{ den, collectors, ... }:
{
  den.quirks.binary-caches.desc = "Binary-cache records { url, publicKey, kind } emitted by cache services (kind = ncps/harmonia) and external-cache aspects (kind = external); collected at host scope for ncro, ncps and harmonia-client consumers.";

  den.policies.collect-binary-caches = collectors.collectAllHosts "binary-caches";

  den.schema.host.includes = [ den.policies.collect-binary-caches ];
}
