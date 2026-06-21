{ den, ... }:
{
  den.aspects.roles.desktop = {
    includes = with den.aspects; [
      audio
      fonts
      keyring
      polkit

      claude
      ai.extensions
      terminal
      messaging.discord
      yazi
      yazi-flavor
      mpv
      imv
      browser
      cad
      kde-connect
    ];
  };
}
