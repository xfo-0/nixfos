{
  inputs,
  lib,
  ...
}:
{
  flake-file.inputs.inshellah.url = "git+https://git.lobotomise.me/atagen/inshellah";

  den.aspects.inshellah = {
    nushellExternalCompleterPrimary.externalCompleterPrimary = ''
      source ${inputs.inshellah}/nix/inshellah-completer.nu
      let primary_completer = $env.config.completions.external.completer
    '';

    nixos =
      { pkgs, ... }:
      {
        imports = [ inputs.inshellah.nixosModules.default ];

        programs.inshellah = {
          enable = true;
          package = lib.mkForce pkgs.local.inshellah;
          workers = 1;
          timeoutMs = 200;
          ignoreCommands = [
            "logoutd"
            "agetty"
            "getty"
            "mingetty"
            "sulogin"
          ];
        };
      };
  };
}
