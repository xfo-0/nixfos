{ lib, den, ... }:
let
  dedupListModule = {
    options = {
      directories = lib.mkOption {
        type = with lib.types; listOf anything;
        default = [ ];
        apply = lib.unique;
      };
      files = lib.mkOption {
        type = with lib.types; listOf anything;
        default = [ ];
        apply = lib.unique;
      };
    };
  };

  hmAdaptArgs =
    userName: args:
    let
      hmConfig = args.config.home-manager.users.${userName};
    in
    {
      inherit hmConfig;
      osConfig = args.config;
      config = hmConfig;
      inherit (args) pkgs;
      inputs' = args.inputs'.${userName} or args.inputs';
    };
  hmAdaptArgv = {
    config = false;
    pkgs = false;
    inputs' = false;
  };

  mkSystemRoute =
    {
      fromClass,
      path,
      adapterKey ? "system-route/${fromClass}",
      adapterModule ? null,
      guard ? null,
      guardArgs ? { },
    }:
    args@{ host, ... }:
    lib.optional (host.class == "nixos" && !(args ? user)) (
      den.lib.policy.route (
        {
          inherit fromClass path adapterKey;
          intoClass = "nixos";
        }
        // lib.optionalAttrs (adapterModule != null) { inherit adapterModule; }
        // lib.optionalAttrs (guard != null) { inherit guard guardArgs; }
      )
    );

  mkUserRoute =
    {
      fromClass,
      path,
      adapterKey ? null,
      adapterModule ? null,
      guard ? null,
      guardArgs ? { },
    }:
    args@{ host, user, ... }:
    lib.optional
      (host.class == "nixos" && lib.elem "homeManager" (user.classes or [ ]) && !(args ? home))
      (
        den.lib.policy.route (
          {
            inherit fromClass path;
            intoClass = "nixos";
            adapterKey = if adapterKey != null then adapterKey else "user-route/${fromClass}/${user.userName}";
            adaptArgs = a: {
              osConfig = a.config;
              hmConfig = a.config.home-manager.users.${user.userName};
            };
            adaptArgv.config = false;
          }
          // lib.optionalAttrs (adapterModule != null) { inherit adapterModule; }
          // lib.optionalAttrs (guard != null) { inherit guard guardArgs; }
        )
      );

  mkHmRoute =
    {
      fromClass,
      hmPath,
      adapterKey ? null,
      adapterModule ? null,
    }:
    args@{ host, user, ... }:
    lib.optional
      (host.class == "nixos" && lib.elem "homeManager" (user.classes or [ ]) && !(args ? home))
      (
        den.lib.policy.route (
          {
            inherit fromClass;
            intoClass = "nixos";
            path = [
              "home-manager"
              "users"
              user.userName
            ]
            ++ hmPath;
            adapterKey = if adapterKey != null then adapterKey else "hm-route/${fromClass}/${user.userName}";
            adaptArgs = hmAdaptArgs user.userName;
            adaptArgv = hmAdaptArgv;
          }
          // lib.optionalAttrs (adapterModule != null) { inherit adapterModule; }
        )
      );
in
{
  _module.args.routes = {
    inherit
      dedupListModule
      hmAdaptArgs
      hmAdaptArgv
      mkSystemRoute
      mkUserRoute
      mkHmRoute
      ;
  };
}
