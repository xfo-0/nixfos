{
  lib,
  den,
  inputs,
  config,
  ...
}:
let
  inherit (lib) mkOption types;
  secretsRoot = config.den.secretsConfig.root;
in
{
  config.den.schema.environment.imports = [
    (
      { name, ... }:
      {
        options = {
          aspect = mkOption {
            type = types.raw;
            default = if den.aspects ? ${name} then den.aspects.${name} else { };
            defaultText = lib.literalExpression "den.aspects.<name>";
            description = "Aspect that configures this environment.";
          };

          domain = mkOption {
            type = types.str;
            description = "Base domain for the environment.";
          };

          secretPath = mkOption {
            type = types.nullOr types.path;
            default = null;
            description = "Path to this environment's secret root.";
          };

          timezone = mkOption {
            type = types.str;
            default = "UTC";
            description = "Default timezone for the environment.";
          };

          location = mkOption {
            type = types.submodule {
              options = {
                country = mkOption {
                  type = types.str;
                  default = "US";
                  description = "ISO country code.";
                };
                region = mkOption {
                  type = types.str;
                  default = "";
                  description = "Geographic region or datacenter.";
                };
              };
            };
            default = { };
            description = "Geographic location information.";
          };

          networks = mkOption {
            type = types.attrsOf (
              types.submodule {
                options = {
                  cidr = mkOption {
                    type = types.str;
                    description = "Network CIDR (e.g., 192.168.12.0/24).";
                  };
                  gatewayIp = mkOption {
                    type = types.nullOr types.str;
                    default = null;
                  };
                  dnsServers = mkOption {
                    type = types.listOf types.str;
                    default = [ ];
                  };
                  assignments = mkOption {
                    type = types.attrsOf types.str;
                    default = { };
                    description = "Hostname → IP assignment map within this network.";
                  };
                };
              }
            );
            default = { };
            description = "Network definitions; assignments map hostnames to static IPs.";
          };

          settings =
            mkOption {
              type = types.attrsOf (types.attrsOf types.anything);
              default = { };
              description = "Environment-level default settings for scope-engine cascade.";
            }
            // {
              identity = false;
            };

          system-access-groups = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = "System-scoped groups that grant Unix account creation on all hosts in this environment.";
          };

          access = mkOption {
            type = types.attrsOf (types.listOf types.str);
            default = { };
            description = "Maps usernames to lists of group names granted within this environment.";
          };
        };

        config.secretPath = lib.mkDefault "${secretsRoot}/env/${name}";
      }
    )
  ];

  options.den.environments = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule (
        { name, ... }:
        {
          freeformType = lib.types.attrsOf lib.types.anything;
          imports = [ den.schema.environment ];
          options.name = lib.mkOption {
            type = lib.types.str;
            default = name;
            description = "Environment name.";
          };
        }
      )
    );
    default = { };
    description = "Environment definitions for fleet topology and scope-engine cascade.";
    visible = false;
  };
}
