{ config, lib, ... }:
{
  options.flake.nh = lib.mkOption {
    type = lib.types.raw;
    default = { };
    description = "nh-deploy fleet metadata (nh.nodes.<name>) derived from the den host registry.";
  };

  config.flake.nh.nodes = lib.pipe (config.den.hosts or { }) [
    builtins.attrValues
    (map builtins.attrNames)
    builtins.concatLists
    (map (
      name:
      let
        hosts = lib.foldl' (acc: sys: acc // (config.den.hosts.${sys} or { })) { } (
          builtins.attrNames config.den.hosts
        );
        host = hosts.${name};
        aspectTags = lib.pipe (host.aspects or [ ]) [
          (map (a: a.identity or ""))
          (lib.filter (i: lib.hasPrefix "roles/" i || lib.hasPrefix "services/" i))
          (map (i: lib.last (lib.splitString "/" i)))
        ];
        primaryUser = host.primaryUser or null;
        deployUser = host.settings.deploy.user or (if primaryUser != null then primaryUser else "root");
        target = if (host.ip or null) != null then host.ip else name;
      in
      {
        inherit name;
        value = {
          hostname = "${deployUser}@${target}";
          tags = lib.unique ([ (host.environment or "prod") ] ++ aspectTags);
          build_on_target = host.settings.deploy.buildOnTarget or false;
          ssh_opts = host.settings.deploy.sshOpts or [ ];
        }
        // lib.optionalAttrs ((host.settings.deploy.port or null) != null) {
          target_port = host.settings.deploy.port;
        };
      }
    ))
    builtins.listToAttrs
  ];
}
