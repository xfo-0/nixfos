{
  den.aspects.atuin = {
    homeManager =
      { lib, ... }:
      {
        programs.atuin = {
          enable = lib.mkDefault true;
          enableNushellIntegration = lib.mkDefault true;
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
