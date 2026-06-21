{
  den.aspects.nodejs = {
    homeManager =
      { pkgs, config, ... }:
      {
        home.packages = [ pkgs.nodejs ];
        home.file.".npmrc".text = "prefix=${config.home.homeDirectory}/.local\n";
      };
  };
}
