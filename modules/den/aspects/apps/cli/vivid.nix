{
  den.aspects.vivid = {
    homeManager = {
      programs.vivid = {
        enable = true;
        enableNushellIntegration = true;
      };
    };

    persistUser =
      { hmConfig, ... }:
      {
        directories = [
          {
            directory = "${hmConfig.xdg.configHome}/vivid";
            how = "symlink";
          }
        ];
      };
  };
}
