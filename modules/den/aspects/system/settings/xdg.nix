{ inputs, den, ... }:
{
  den.schema.host.includes = [ den.aspects.xdg-sys ];
  den.schema.user.includes = [ den.aspects.xdg-user ];

  den.aspects.xdg-sys = {
    nixos.environment.pathsToLink = [
      "/share/xdg-desktop-portal"
      "/share/applications"
    ];
  };

  den.aspects.xdg-user = {
    homeManager =
      {
        config,
        pkgs,
        lib,
        ...
      }:
      {
        xdg = {
          enable = lib.mkDefault true;
          mimeApps.enable = lib.mkDefault true;
          autostart.enable = lib.mkDefault true;

          userDirs =
            let
              docs = config.xdg.userDirs.documents;
            in
            inputs.self.lib.applyDefaults {
              enable = config.xdg.enable;
              createDirectories = true;
              setSessionVariables = true;
              documents = "${config.home.homeDirectory}/Documents";
              download = "${docs}/Downloads";
              pictures = "${docs}/Pictures";
              projects = "${docs}/projects";
              desktop = docs;
              videos = docs;
              music = docs;
              templates = docs;
              publicShare = null;
            };

          dataFile."mimeapps.list" = lib.mkDefault {
            source = "${config.xdg.configFile."mimeapps.list".source}";
            force = true;
          };

          portal = {
            enable = lib.mkDefault config.xdg.enable;
            extraPortals = lib.mkDefault [
              pkgs.xdg-desktop-portal-gnome
              pkgs.xdg-desktop-portal-gtk
            ];
            config.common.default = lib.mkDefault [
              "gnome"
              "gtk"
            ];
          };
        };

        home = {
          preferXdgDirectories = lib.mkDefault config.xdg.enable;
          packages = with pkgs; [ xdg-ninja ];
        };
      };

    persistUser =
      { hmConfig, ... }:
      {
        directories = [
          {
            directory = "${hmConfig.xdg.userDirs.documents}";
            how = "symlink";
            createLinkTarget = true;
          }
        ];

        files = [
          {
            file = "${hmConfig.xdg.dataHome}/recently-used.xbel";
            mode = "0600";
          }
        ];
      };

    persistUserTmp =
      { hmConfig, ... }:
      {
        ".local" = { };
        "${hmConfig.xdg.configHome}" = { };
        "${hmConfig.xdg.dataHome}" = { };
        "${hmConfig.xdg.cacheHome}" = { };
        "${hmConfig.xdg.stateHome}" = { };
      };
  };
}
