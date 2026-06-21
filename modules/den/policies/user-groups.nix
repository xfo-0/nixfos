# ACL-driven group consumption.
#
# Creates the novel user-role gate groups (posix + user-role labels) as real
# NixOS groups with their den.groups gid, then sets each resolved user's
# extraGroups from the scope-engine ACL (resolveUser.systemGroups — the
# transitive posix closure of the user's registry groups). Membership is mapped
# by name; gids for NixOS-owned device groups (audio, video, …) are left to
# NixOS, so systemGroups is filtered to groups that actually exist on the host.
{
  lib,
  config,
  den,
  ...
}:
let
  gateGroups = lib.filterAttrs (
    _: g: (lib.elem "posix" g.labels) && (lib.elem "user-role" g.labels)
  ) (config.den.groups or { });

  createGates = _: {
    name = "acl-gate-groups";
    nixos.users.groups = lib.mapAttrs (_: g: { gid = g.gid; }) gateGroups;
  };

  aclExtraGroups =
    { host, user }:
    let
      aclUser = config.fleet.acl.get "host:${host.name}" "resolveUser" user.userName;
    in
    {
      name = "acl-groups/${user.userName}@${host.name}";
      nixos =
        { config, ... }:
        {
          users.users.${user.userName}.extraGroups = builtins.filter (
            g: config.users.groups ? ${g}
          ) aclUser.systemGroups;
        };
    };
in
{
  den.schema.host.includes = [ createGates ];
  den.schema.user.includes = [ aclExtraGroups ];
}
