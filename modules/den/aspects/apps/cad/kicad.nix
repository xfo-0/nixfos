{
  den.aspects.kicad =
    { host, ... }:
    {
      homeManager =
        { pkgs, lib, ... }:
        lib.mkIf (host.settings.capabilities.workstation.enable or false) {
          home.packages = [ pkgs.kicad ];
        };

      persistUser =
        { hmConfig, ... }:
        {
          directories = [
            {
              directory = "${hmConfig.xdg.configHome}/kicad";
              mode = "0700";
              how = "symlink";
              createLinkTarget = true;
            }
            {
              directory = "${hmConfig.xdg.dataHome}/kicad";
              mode = "0700";
              how = "symlink";
              createLinkTarget = true;
            }
          ];
        };
    };
}
