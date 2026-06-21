{ den, lib, ... }:
{
  den.aspects.audio = {
    includes = [
      den.aspects.audio.pipewire
    ];

    pipewire = {
      nixos =
        { lib, ... }:
        {
          services = {
            pulseaudio.enable = lib.mkDefault false;
            pipewire = {
              enable = lib.mkDefault true;
              alsa.enable = lib.mkDefault true;
              alsa.support32Bit = lib.mkDefault true;
              pulse.enable = lib.mkDefault true;
              wireplumber.enable = lib.mkDefault true;
              extraConfig.pipewire."10-clock-rates" = {
                "context.properties" = {
                  "default.clock.rate" = 48000;
                  "default.clock.allowed-rates" = [
                    44100
                    48000
                    88200
                    96000
                    176400
                    192000
                    384000
                  ];
                };
              };
            };
          };
          security.rtkit.enable = lib.mkDefault true;
        };

      persistUser =
        { hmConfig, ... }:
        {
          directories = [
            {
              directory = "${hmConfig.xdg.stateHome}/wireplumber";
              how = "symlink";
            }
          ];
        };
    };
  };
}
