{ den, ... }:
{
  den.aspects.roles.gaming = {
    includes = with den.aspects; [
      roles.desktop
      lact
      ananicy
    ];
  };
}
