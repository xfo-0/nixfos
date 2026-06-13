{ den, lib, collectors, ... }:
{
  den.quirks.host-info.desc = "Host network identity ({ name, ip, publicKey }). Emitted parametrically by host aspects, collected at host scope.";

  den.aspects._host-info-emit = {
    host-info =
      { host, ... }:
      lib.optional (host.ip != null && host.publicKey != null) {
        inherit (host) name ip publicKey;
      };
  };

  den.policies.collect-host-info = collectors.collectAllHosts "host-info";

  den.schema.host.includes = [
    den.aspects._host-info-emit
    den.policies.collect-host-info
  ];
}
