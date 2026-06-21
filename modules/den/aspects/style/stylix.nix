{
  inputs,
  lib,
  ...
}:
let
  promoteToHost =
    { module, derive }:
    { user, host, ... }:
    {
      nixos =
        { config, lib, ... }:
        {
          imports = [ module ];
          config =
            lib.mkIf
              (
                (host.settings.capabilities.graphical.enable or false)
                && (host.primaryUser or null) == user.userName
                && (config.home-manager.users ? ${user.userName})
              )
              (derive {
                hm = config.home-manager.users.${user.userName};
                inherit host config lib;
              });
        };
    };
in
{
  flake-file.inputs.stylix.url = "gh:danth/stylix";

  den.aspects.stylix = {
    includes = [
      (promoteToHost {
        module = inputs.stylix.nixosModules.stylix;
        derive =
          { hm, ... }:
          {
            stylix = {
              enable = true;
              polarity = hm.stylix.polarity;
              base16Scheme = hm.stylix.base16Scheme;
              fonts = {
                inherit (hm.stylix.fonts)
                  serif
                  sansSerif
                  monospace
                  emoji
                  sizes
                  ;
              };
              homeManagerIntegration.autoImport = false;
            };
          };
      })
    ];

    homeManager =
      {
        config,
        pkgs,
        ...
      }:
      {
        imports = [ inputs.stylix.homeModules.stylix ];


        stylix = {
          enableReleaseChecks = lib.mkDefault false;
          enable = lib.mkDefault true;
          polarity = lib.mkDefault "dark";
          autoEnable = lib.mkDefault true;
          fonts = {
            serif = {
              name = "IoskeleyMonoTerm Nerd Font";
              package = pkgs.ioskeley-mono.normal-term-NF;
            };
            sansSerif = {
              name = "IoskeleyMonoTerm Nerd Font";
              package = pkgs.ioskeley-mono.normal-term-NF;
            };
            monospace = {
              name = "IoskeleyMonoTerm Nerd Font";
              package = pkgs.ioskeley-mono.normal-term-NF;
            };
            emoji = {
              name = "Noto Color Emoji";
              package = pkgs.noto-fonts-color-emoji;
            };
            sizes = {
              terminal = 12;
              applications = 12;
              popups = 12;
            };
          };
          targets = {
            gnome.enable = lib.mkForce false;
            kde.enable = lib.mkForce false;
            starship.colors.override = {
              withHashtag = with config.lib.stylix.colors.withHashtag; {
                bright-yellow = base0A;
              };
            };
          };
        };

        # gtk.gtk4.theme = config.gtk.theme;
      };
  };
}
