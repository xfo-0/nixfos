{
  den.aspects.zoxide = {
    homeManager =
      { lib, ... }:
      {
        programs.zoxide = {
          enable = lib.mkDefault true;
          enableNushellIntegration = lib.mkDefault true;
        };
      };

    persistUser =
      { hmConfig, ... }:
      {
        directories = [
          {
            directory = "${hmConfig.xdg.dataHome}/zoxide";
            how = "symlink";
          }
        ];
      };

  };
}
