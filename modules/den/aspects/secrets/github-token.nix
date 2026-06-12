{ inputs, ... }:
{
  den.aspects.secrets.github-token = {
    nixos =
      { host, ... }:
      {
        sops.secrets."github/token" = {
          sopsFile = "${inputs.self}/.secrets/common/github.yaml";
          owner = host.primaryUser or "root";
        };
      };
  };
}
