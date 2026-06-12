{
  inputs,
  den,
  ...
}:
{
  flake-file.inputs.sops-nix.url = "gh:Mic92/sops-nix";

  den.aspects.sops-infra = {
    _.sys = {
      nixos =
        {
          pkgs,
          lib,
          ...
        }:
        {
          imports = [ inputs.sops-nix.nixosModules.sops ];

          environment.systemPackages = with pkgs; [
            age
            sops
            ssh-to-age
          ];

          sops.age.sshKeyPaths = lib.mkDefault [ "/etc/ssh/ssh_host_ed25519_key" ];
        };
    };
  };
}
