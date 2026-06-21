{
  den.aspects.cli.tools.cli-tools = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          ripgrep
          ripgrep-all
          ast-grep
          fd
          tokei
          parted
          smartmontools
          nvme-cli
          hdparm
          file
          tree
          which
          wget
          curl
          gnused
          gawk
          jq
        ];
      };
  };
}
