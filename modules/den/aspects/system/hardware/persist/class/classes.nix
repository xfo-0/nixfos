{
  den,
  lib,
  routes,
  ...
}:
let
  # persist's guard: only fire if the host has the preservation module imported,
  # and (when applicable) only if find-ephemeral is in systemPackages. The
  # second clause exists for the `*Ignore` routes which feed find-ephemeral.
  mkPersistGuard =
    requiresFindEphemeral:
    {
      config,
      options,
      ...
    }:
    let
      hasPreservation = options ? preservation;
      hasFindEphemeral = lib.any (
        pkg: (pkg.name or "") == "find-ephemeral"
      ) config.environment.systemPackages;
    in
    cfg: lib.mkIf (hasPreservation && (!requiresFindEphemeral || hasFindEphemeral)) cfg;

  guardArgs = {
    config = false;
    options = false;
  };

  mkSystemPersistRoute =
    {
      fromClass,
      path,
      dedup ? false,
      requiresFindEphemeral ? false,
    }:
    let
      base = routes.mkSystemRoute {
        inherit fromClass path;
        adapterKey = "persist-route/${fromClass}";
        inherit guardArgs;
        guard = mkPersistGuard requiresFindEphemeral;
        adapterModule = if dedup then routes.dedupListModule else null;
      };
    in
    args@{ host, ... }:
    lib.optionals (host.settings.capabilities.persistent.enable or false) (base args);

  mkUserPersistRoute =
    {
      fromClass,
      intoSubPath,
      dedup ? false,
      requiresFindEphemeral ? false,
    }:
    args@{ host, user, ... }:
    lib.optional
      (
        (host.settings.capabilities.persistent.enable or false)
        && host.class == "nixos"
        && lib.elem "homeManager" (user.classes or [ ])
        && !(args ? home)
      )
      (
        den.lib.policy.route (
          {
            inherit fromClass;
            intoClass = "nixos";
            path = [
              "hostConfig"
              "preservation"
              intoSubPath
              user.userName
            ];
            adapterKey = "persist-route/${fromClass}/${user.userName}";
            inherit guardArgs;
            guard = mkPersistGuard requiresFindEphemeral;
            adaptArgs = a: {
              osConfig = a.config;
              hmConfig = a.config.home-manager.users.${user.userName};
            };
            adaptArgv.config = false;
          }
          // lib.optionalAttrs dedup { adapterModule = routes.dedupListModule; }
        )
      );
in
{
  # System-level persist classes (routed to preservation.preserveAt and friends)
  den.classes.persist.description = "Persist directories/files into /persist";
  den.classes.persistTmp.description = "Persist tmpfile entries (forwarded to preservation.tmpfiles)";
  den.classes.persistIgnore.description = "Paths excluded from find-ephemeral scans";
  # User-level persist classes (routed under hostConfig.preservation.user{Persist,Tmpfiles,Ignore}.<userName>)
  den.classes.persistUser.description = "Persist user-relative directories/files";
  den.classes.persistUserTmp.description = "Persist user-relative tmpfile entries";
  den.classes.persistUserIgnore.description = "User-relative paths excluded from find-ephemeral scans";
  den.classes.persistReplicated.description = "Persist + register crucial paths for cross-host replication";

  den.policies.persist-route = mkSystemPersistRoute {
    fromClass = "persist";
    path = [
      "preservation"
      "preserveAt"
      "/persist"
    ];
    dedup = true;
  };
  den.policies.persistTmp-route = mkSystemPersistRoute {
    fromClass = "persistTmp";
    path = [
      "hostConfig"
      "preservation"
      "tmpfiles"
    ];
  };
  den.policies.persistIgnore-route = mkSystemPersistRoute {
    fromClass = "persistIgnore";
    path = [
      "hostConfig"
      "preservation"
      "ignore"
    ];
    dedup = true;
    requiresFindEphemeral = true;
  };

  den.policies.persistReplicated-route = mkSystemPersistRoute {
    fromClass = "persistReplicated";
    path = [
      "hostConfig"
      "replication"
    ];
    dedup = true;
  };

  den.policies.persistUser-route = mkUserPersistRoute {
    fromClass = "persistUser";
    intoSubPath = "userPersist";
    dedup = true;
  };
  den.policies.persistUserTmp-route = mkUserPersistRoute {
    fromClass = "persistUserTmp";
    intoSubPath = "userTmpfiles";
  };
  den.policies.persistUserIgnore-route = mkUserPersistRoute {
    fromClass = "persistUserIgnore";
    intoSubPath = "userIgnore";
    dedup = true;
    requiresFindEphemeral = true;
  };

  den.default.includes = [
    den.policies.persist-route
    den.policies.persistTmp-route
    den.policies.persistIgnore-route
    den.policies.persistReplicated-route
  ];

  # The classes aspect is now empty of routing logic — kept as a structural
  # marker so existing `<persist/class>` includes don't break.
  den.aspects.persist._.class._.classes = { };
}
