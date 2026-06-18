{
  den.aspects.atuin = {
    homeManager =
      { lib, ... }:
      {
        programs.atuin = {
          enable = lib.mkDefault true;
          enableNushellIntegration = lib.mkDefault true;
          settings = {
            sync_address = "http://grpht.tail0df4ba.ts.net:8888";
            auto_sync = true;
            sync_frequency = "10m";
          };
        };
      };

    persistUser =
      { hmConfig, ... }:
      {
        directories = [
          {
            directory = "${hmConfig.xdg.dataHome}/atuin";
            how = "symlink";
          }
        ];
      };

    persistUserIgnore =
      { hmConfig, ... }:
      {
        directories = [ "${hmConfig.xdg.configHome}/atuin" ];
      };
  };
}
