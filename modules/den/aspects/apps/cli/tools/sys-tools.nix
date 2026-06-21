{
  den.aspects.cli.tools.sys-tools = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          iotop
          iftop
          strace
          ltrace
          lsof
        ];
      };
  };
}
