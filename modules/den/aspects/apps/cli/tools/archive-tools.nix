{
  den.aspects.cli.tools.archive-tools = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          zip
          unzip
          xz
          p7zip
          gnutar
          ouch
        ];
      };
  };
}
