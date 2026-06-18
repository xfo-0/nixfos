{
  den.aspects.orca-slicer =
    { host, ... }:
    {
      homeManager =
        { pkgs, lib, ... }:
        lib.mkIf (host.settings.capabilities.workstation.enable or false) {
          home.packages = [ pkgs.orca-slicer ];
        };

      persistUser =
        { hmConfig, ... }:
        {
          directories = [
            {
              directory = "${hmConfig.xdg.configHome}/OrcaSlicer";
              mode = "0700";
              how = "symlink";
              createLinkTarget = true;
            }
            {
              directory = "${hmConfig.xdg.dataHome}/orca-slicer";
              mode = "0700";
              how = "symlink";
              createLinkTarget = true;
            }
          ];
        };
    };
}
