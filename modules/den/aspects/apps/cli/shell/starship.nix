{
  den.aspects.starship = {
    homeManager =
      { lib, ... }:
      {
        programs.starship = {
          enable = lib.mkDefault true;
          enableNushellIntegration = lib.mkDefault true;
          settings = {
            add_newline = lib.mkDefault true;
            aws.disabled = lib.mkDefault true;
            gcloud.disabled = lib.mkDefault true;
            line_break.disabled = lib.mkDefault false;
          };
        };
      };
  };
}
