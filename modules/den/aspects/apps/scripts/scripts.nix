{ den, ... }:
{
  den.aspects.scripts-user = {
    nixos.environment.localBinInPath = true;

    persistUser = {
      directories = [
        {
          directory = ".local/bin";
        }
      ];
    };

    persistUserTmp = {
      ".local" = { };
    };
  };
}
