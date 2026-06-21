{ inputs, ... }:
{
  den.aspects.secrets.github-token = {
    nixos =
      { host, config, ... }:
      {
        sops.secrets."github/token" = {
          sopsFile = "${inputs.self}/.secrets/common/github.yaml";
          owner = host.primaryUser or "root";
        };
        sops.templates."nix-access-tokens" = {
          content = "access-tokens = github.com=${config.sops.placeholder."github/token"}";
          owner = host.primaryUser or "root";
        };
        nix.extraOptions = "!include ${config.sops.templates."nix-access-tokens".path}";
      };
  };
}
