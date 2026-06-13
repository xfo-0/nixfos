{
  den,
  lib,
  routes,
  inputs,
  ...
}:
{
  flake-file.inputs.niri.url = "gh:cmm/niri-flake/0d251ae03aa211fb241b1958e06f250c51980a96";

  den = {

    classes.niri.description = "Niri window-manager config (forwarded to home-manager.programs.niri)";

    policies.niri-route = routes.mkHmRoute {
      fromClass = "niri";
      hmPath = [
        "programs"
        "niri"
      ];
      adapterModule = {
        options.settings = {
          spawn-at-startup = lib.mkOption {
            type = with lib.types; listOf anything;
            default = [ ];
          };
          window-rules = lib.mkOption {
            type = with lib.types; listOf anything;
            default = [ ];
          };
          layer-rules = lib.mkOption {
            type = with lib.types; listOf anything;
            default = [ ];
          };
          binds = lib.mkOption {
            type = with lib.types; attrsOf anything;
            default = { };
          };
        };
      };
    };

    aspects.niri = {
      class.route = { };

      includes = [
        den.policies.niri-route
        den.aspects.niri.class
        den.aspects.niri.config
        den.aspects.niri.enable
        den.aspects.niri.rules
        den.aspects.niri.settings
      ];

      config = {
        homeManager =
          {
            pkgs,
            lib,
            ...
          }:
          {
            home.packages = with pkgs; [
              wl-clipboard
              cliphist
            ];

            programs.niri = {
              package = lib.mkDefault pkgs.niri;

              settings = {
                xwayland-satellite = {
                  enable = lib.mkDefault true;
                  path = lib.mkDefault "${lib.getExe pkgs.xwayland-satellite}";
                };

                spawn-at-startup = [
                  { command = [ "wl-gammarelay-rs" ]; }
                  {
                    command = [
                      "sh"
                      "-c"
                      "wl-paste --watch cliphist store"
                    ];
                  }
                ];
              };
            };
          };
      };

      enable = {
        nixos =
          { pkgs, lib, ... }:
          {
            imports = [ inputs.niri.nixosModules.niri ];

            programs.niri = {
              enable = lib.mkDefault true;
              package = lib.mkDefault pkgs.niri;
            };
            systemd.user.services.niri-flake-polkit.enable = lib.mkDefault false;
          };
      };
    };
  };
}
