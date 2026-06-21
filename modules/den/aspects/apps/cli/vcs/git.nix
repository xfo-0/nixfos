{
  den,
  lib,
  routes,
  ...
}:
{
  den.classes.git.description = "Git config (forwarded to home-manager.programs.git)";

  den.policies.git-route = routes.mkHmRoute {
    fromClass = "git";
    hmPath = [
      "programs"
      "git"
    ];
  };
  den.default.includes = [ den.policies.git-route ];

  den.aspects.git = {
    includes = [
      den.aspects.git.enable
    ];

    enable = {
      homeManager =
        { lib, ... }:
        {
          programs.git = {
            enable = lib.mkDefault true;
            settings = {
              init.defaultBranch = lib.mkDefault "main";
            };
          };
        };
    };
  };

  den.aspects.gh = {
    homeManager =
      { lib, ... }:
      {
        programs.gh = {
          enable = lib.mkDefault true;
          settings.git_protocol = lib.mkDefault "https";
          gitCredentialHelper = {
            enable = lib.mkDefault true;
          };
        };
      };

    persistUserTmp =
      { hmConfig, ... }:
      {
        "${hmConfig.xdg.configHome}" = { };
        "${hmConfig.xdg.configHome}/gh" = { };
      };
  };
}
