{
  lib,
  config,
  den,
  ...
}:
let
  inherit (lib) mkOption types;

  shadow = high: low: lib.recursiveUpdate low high;

  flatHosts = lib.foldl' (acc: system: acc // (den.hosts.${system} or { })) { } (
    builtins.attrNames (den.hosts or { })
  );

  environments = config.den.environments or { };
  hosts = flatHosts;

  envNames = builtins.attrNames environments;
  hostNames = builtins.attrNames hosts;

  nodes = lib.listToAttrs (
    [
      {
        name = "root";
        value = {
          type = "root";
          parent = null;
          imports = [ ];
          decls = { };
        };
      }
    ]
    ++ map (ename: {
      name = "env:${ename}";
      value = {
        type = "environment";
        parent = "root";
        imports = [ ];
        decls = environments.${ename}.settings or { };
      };
    }) envNames
    ++ map (hname: {
      name = "host:${hname}";
      value = {
        type = "host";
        parent = "env:${hosts.${hname}.environment or "prod"}";
        imports = [ ];
        decls = hosts.${hname}.settings or { };
      };
    }) hostNames
  );

  evalNode = id: node: rec {
    resolvedSettings =
      let
        importedSettings = lib.foldl' (
          acc: iid: shadow (evaluated.${iid}.resolvedSettings or { }) acc
        ) { } node.imports;
        parentSettings =
          if node.parent != null && evaluated ? ${node.parent} then
            evaluated.${node.parent}.resolvedSettings
          else
            { };
      in
      shadow node.decls (shadow importedSettings parentSettings);

    overriddenKeys =
      let
        sourceCount =
          key: sourceId:
          let
            sourceNode = nodes.${sourceId};
            parentCount =
              if sourceNode.parent != null && nodes ? ${sourceNode.parent} then
                sourceCount key sourceNode.parent
              else
                0;
            importCount = lib.foldl' (
              acc: iid: acc + (if nodes ? ${iid} then sourceCount key iid else 0)
            ) 0 sourceNode.imports;
            localCount = if sourceNode.decls ? ${key} then 1 else 0;
          in
          localCount + importCount + parentCount;
      in
      builtins.filter (key: sourceCount key id > 1) (builtins.attrNames node.decls);

    settingSources = lib.mapAttrs (
      key: _:
      if node.decls ? ${key} then
        "local"
      else if builtins.any (iid: (evaluated.${iid}.resolvedSettings or { }) ? ${key}) node.imports then
        "import"
      else
        "inherited"
    ) resolvedSettings;
  };

  evaluated = lib.mapAttrs evalNode nodes;
in
{
  options.fleet.settings = mkOption {
    type = types.raw;
    description = "Evaluated settings cascade graph from scope-engine.";
    readOnly = true;
  };

  config.fleet.settings = {
    inherit nodes evaluated;
    environments = lib.genAttrs envNames (name: evaluated."env:${name}".resolvedSettings);
    hosts = lib.genAttrs hostNames (name: evaluated."host:${name}".resolvedSettings);
  };
}
