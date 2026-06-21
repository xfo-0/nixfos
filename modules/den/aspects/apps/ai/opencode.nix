{ den, ... }:
{
  den.aspects.opencode = {
    includes = [
      den.aspects.nodejs
      den.aspects.python
      den.aspects.ai.extensions
    ];

    homeManager =
      { inputs', ... }:
      {
        home.packages = [ inputs'.llm-agents.packages.opencode ];
      };

    persistUser =
      { hmConfig, ... }:
      {
        directories = [
          {
            directory = "${hmConfig.xdg.configHome}/opencode";
            how = "symlink";
          }
          {
            directory = "${hmConfig.xdg.dataHome}/opencode";
            how = "symlink";
          }
          {
            directory = "${hmConfig.xdg.cacheHome}/opencode";
            how = "symlink";
          }
          {
            directory = "${hmConfig.xdg.configHome}/lean-ctx";
            how = "symlink";
          }
          {
            directory = ".lean-ctx";
            how = "symlink";
          }
        ];
      };
  };
}
