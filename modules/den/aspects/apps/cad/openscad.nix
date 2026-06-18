{
  den.aspects.openscad =
    { host, ... }:
    {
      homeManager =
        { pkgs, lib, ... }:
        lib.mkIf (host.settings.capabilities.workstation.enable or false) {
          home.packages = [ pkgs.openscad-unstable ];
        };

      persistUser =
        { hmConfig, ... }:
        {
          directories = [
            {
              directory = "${hmConfig.xdg.configHome}/OpenSCAD";
              mode = "0700";
              how = "symlink";
              createLinkTarget = true;
            }
          ];
        };
    };
}
