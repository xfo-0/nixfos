{ den, ... }:
{
  den.aspects.core.default = {
    includes = with den.aspects; [
      persist
      nix-config
      bat
      btop
      direnv
      nh
      nodejs
      npins
      python
      tack
      television
      cli.tools
      vivid
      zathura
      zellij
      rmux
      atuin
      bash
      carapace
      inshellah
      nushell
      starship
      zoxide
      kanso
      stylix
      gh
      git
      jj
      rbw
      repos
    ];
  };
}
