{
  den.aspects.fosi-ds2 = {
    nixos.services.pipewire.wireplumber.extraConfig."fosi-ds2" = {
      "monitor.alsa.rules" = [
        {
          matches = [
            {
              "node.name" = "alsa_output.usb-Speed_Dragon_Fosi_Audio_DS2_5000000001-01.analog-stereo";
            }
          ];
          actions.update-props = {
            "audio.format" = "S32LE";
            "audio.allowed-rates" = "44100,48000,88200,96000,176400,192000,384000";
            "priority.session" = 2000;
          };
        }
      ];
    };
  };
}
