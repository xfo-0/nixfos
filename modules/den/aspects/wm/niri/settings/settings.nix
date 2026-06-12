{ den, ... }:
{
  den.aspects.niri.settings.includes = [
    den.aspects.niri.settings.environment
    den.aspects.niri.settings.input
    den.aspects.niri.settings.keybinds
    den.aspects.niri.settings.main
  ];
}
