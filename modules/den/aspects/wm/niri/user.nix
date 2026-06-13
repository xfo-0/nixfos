{ den, ... }:
{
  den.aspects.niri.user-env = (
    { user, ... }:
    {
      homeManager =
        {
          config,
          options,
          lib,
          ...
        }:
        lib.mkIf (options.programs ? niri) {
          programs.niri.settings = {
            binds."Mod+W".action = with config.lib.niri.actions; spawn user.terminal "-e" "zellij";
            environment = {
              EDITOR = user.editor;
              BROWSER = user.browser;
            };
          };
        };
    }
  );

  den.schema.user.includes = [ den.aspects.niri.user-env ];
}
