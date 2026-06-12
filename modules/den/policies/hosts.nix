# Host-level user resolution wiring.
#
# Resolves registry users onto each host whose effective access groups
# (merged env+host gates, computed in fleet env-to-hosts) intersect the
# user's groups. Runs alongside the legacy host.users path until cutover.
{ den, ... }:
{
  den.schema.host.includes = [
    den.policies.env-users
  ];
}
