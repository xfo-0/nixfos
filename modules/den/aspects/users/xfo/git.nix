{ den, lib, ... }:
{
  den.aspects.xfo = {
    includes = [
      den.aspects.xfo.git-config
    ];

    git-config = {
      homeManager =
        { config, ... }:
        {
          sops = {
            secrets = {
              "git/name" = { };
              "git/email" = { };
              "github/token" = { };
            };
            templates = {
              "git-credentials" = {
                content = ''
                  [user]
                    name = "${config.sops.placeholder."git/name"}"
                    email = "${config.sops.placeholder."git/email"}"
                '';
              };
              "gh-hosts-yml" = {
                content = ''
                  github.com:
                    user: xfo
                    oauth_token: ${config.sops.placeholder."github/token"}
                    git_protocol: ssh
                '';
              };
            };
          };
          xdg.configFile."gh/hosts.yml".source =
            config.lib.file.mkOutOfStoreSymlink
              config.sops.templates."gh-hosts-yml".path;
          programs.ssh = {
            enable = true;
          };
        };

      git =
        { config, ... }:
        {
          includes = [
            { path = config.sops.templates."git-credentials".path; }
          ];
          settings.url."git@github.com:".insteadOf = "https://github.com/";
          settings.safe.directory = "${config.home.homeDirectory}/nx";
        };
    };
  };
}
