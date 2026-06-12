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
      opencode
      terminal
      messaging.discord
      yazi
      yazi-flavor
      mpv
      browser
      cad
    ];
  };
}
