{ den, ... }:
{
  den.aspects.apps.ai._cache-emit = {
    binary-caches = _: {
      url = "https://cache.numtide.com";
      publicKey = "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=";
      kind = "external";
    };
  };

  den.schema.host.includes = [ den.aspects.apps.ai._cache-emit ];
}
