{
  lib,
  den,
  config,
  ...
}:
let
  inherit (den.lib.policy) resolve;
  environments = config.den.environments or { };
in
{
  den.policies.to-fleet = _: [
    (resolve.to "fleet" {
      fleet = {
        name = "fleet";
        aspect = { };
      };
    })
  ];

  den.policies.fleet-to-envs =
    _:
    lib.mapAttrsToList (
      _: env:
      resolve.to "environment" {
        environment = env;
      }
    ) environments;

  den.policies.env-to-hosts =
    { environment, ... }:
    let
      inherit (config) fleet;
      envGrant = (fleet.user-access.by-environment.${environment.name} or { groups = [ ]; }).groups;
      envGate = environment.system-access-groups or [ ];
    in
    lib.concatMap (
      system:
      lib.concatMap (
        hostName:
        let
          hostCfg = den.hosts.${system}.${hostName};
          envSettings = environment.settings or { };

          # Derive IP from environment network assignments when not explicit.
          # Hosts set ip explicitly for custom/manual IPs; fleet derives from
          # den.environments.<env>.networks.lan.assignments.<hostName> otherwise.
          assignments = environment.networks.lan.assignments or { };
          hostIp = if hostCfg.ip != null then hostCfg.ip else assignments.${hostName} or null;

          bridgedHost = hostCfg // {
            ip = hostIp;
            settings = lib.recursiveUpdate envSettings (hostCfg.settings or { });
          };

          hostGrant = (fleet.user-access.by-host.${hostName} or { groups = [ ]; }).groups;
          hostGate = hostCfg.system-access-groups or [ ];
          effectiveGate = lib.unique (envGate ++ hostGate);
          allGrants = lib.unique (envGrant ++ hostGrant ++ hostGate);
          accessGroups =
            if effectiveGate == [ ] then
              allGrants
            else
              builtins.filter (g: builtins.elem g effectiveGate) allGrants;
        in
        lib.optionals ((hostCfg.environment or "prod") == environment.name && hostCfg.intoAttr != [ ]) [
          (resolve.to "host" {
            host = bridgedHost;
            inherit accessGroups;
          })
          (den.lib.policy.instantiate bridgedHost)
        ]
      ) (builtins.attrNames (den.hosts.${system} or { }))
    ) (builtins.attrNames (den.hosts or { }));

  den.schema.flake.includes = [ den.policies.to-fleet ];
  den.schema.fleet.includes = [ den.policies.fleet-to-envs ];
  den.schema.environment.includes = [ den.policies.env-to-hosts ];

  den.schema.flake-system.excludes = [
    den.policies.system-to-os-outputs
    den.policies.system-to-hm-outputs
  ];

  # Registry env-users (policies/hosts.nix) replaces den's built-in host-to-users.
  den.schema.host.excludes = [ den.policies.host-to-users ];
}
