# User registry and access-driven user resolution.
#
# Users live in den.users.registry with group memberships. env-users resolves
# registry users onto a host when their groups intersect the host's effective
# access groups. Inert until policies/hosts.nix includes env-users on host scope.
{
  lib,
  den,
  config,
  ...
}:
let
  inherit (den.lib.policy) resolve;
  inherit (lib) mkOption types;

  registry = config.den.users.registry;

  matchRegistryUsers =
    grantedGroups:
    lib.filter (
      name:
      let
        userGroups = registry.${name}.groups or [ ];
      in
      builtins.any (g: lib.elem g grantedGroups) userGroups
    ) (builtins.attrNames registry);

  accessGrantType = types.submodule {
    options.groups = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Groups granted access";
    };
  };

  registryUserType = types.submodule (
    { name, config, ... }:
    {
      freeformType = types.attrsOf types.anything;
      imports = [ den.schema.user ];
      config._module.args.user = config;
      options = {
        name = mkOption {
          type = types.str;
          default = name;
          description = "User name (from attrset key)";
        };
        userName = mkOption {
          type = types.str;
          default = name;
          description = "User account name";
        };
        classes = mkOption {
          type = types.listOf types.str;
          default = [ "homeManager" ];
          description = "Home management nix classes";
        };
        aspect = mkOption {
          type = types.raw;
          default = den.aspects.${name} or { };
          defaultText = "den.aspects.<name>";
          description = "Aspect that configures this user";
        };
        groups = mkOption {
          type = types.listOf types.str;
          default = [ ];
          description = "Group memberships for access policy selection";
        };
      };
    }
  );
in
{
  options.den.users.registry = mkOption {
    type = types.attrsOf registryUserType;
    default = { };
    description = "User registry with extended schema for access resolution";
  };

  options.fleet.user-access = {
    by-environment = mkOption {
      type = types.attrsOf accessGrantType;
      default = { };
      description = "Grant user groups access to all hosts in an environment";
    };
    by-host = mkOption {
      type = types.attrsOf accessGrantType;
      default = { };
      description = "Grant user groups access to a specific host";
    };
  };

  config.den.policies.env-users =
    {
      accessGroups ? [ ],
      ...
    }:
    map (name: resolve.to "user" { user = registry.${name}; }) (matchRegistryUsers accessGroups);
}
