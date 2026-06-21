{
  den.aspects.cli.tools.herdr = {
    nixos =
      { pkgs, ... }:
      let
        herdr = pkgs.stdenvNoCC.mkDerivation rec {
          pname = "herdr";
          version = "0.7.0";

          src = pkgs.fetchurl {
            url = "https://github.com/ogulcancelik/herdr/releases/download/v${version}/herdr-linux-x86_64";
            hash = "sha256-rSpdSApOBGCandMKGewHhUV432tfDqkpkkaWO69ANjs=";
          };

          dontUnpack = true;
          dontStrip = true;

          installPhase = ''
            runHook preInstall
            install -Dm755 $src $out/bin/herdr
            runHook postInstall
          '';

          meta = {
            description = "Agent multiplexer that lives in your terminal";
            homepage = "https://github.com/ogulcancelik/herdr";
            license = pkgs.lib.licenses.agpl3Plus;
            platforms = [ "x86_64-linux" ];
            mainProgram = "herdr";
          };
        };
      in
      {
        environment.systemPackages = [ herdr ];
      };

    homeManager =
      { config, lib, pkgs, ... }:
      {
        home.activation.herdrConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          ${pkgs.coreutils}/bin/rm -f "${config.xdg.configHome}/herdr/config.toml"
          ${pkgs.coreutils}/bin/install -Dm644 ${./herdr-config.toml} "${config.xdg.configHome}/herdr/config.toml"
        '';
      };

    persistUser =
      { hmConfig, ... }:
      {
        directories = [
          {
            directory = "${hmConfig.xdg.configHome}/herdr";
            how = "symlink";
          }
        ];
      };
  };
}
