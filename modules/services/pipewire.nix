{
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber = {
      enable = true;
      extraConfig = {
        "10-displaylink-fix" = {
          "monitor.alsa.rules" = [
            {
              matches = [
                {
                  "device.vendor.id" = "0x17e9";
                }
              ];
              actions = {
                update-props = {
                  "api.alsa.use-acp" = false;
                  "api.alsa.use-ucm" = false;
                  "priority.driver" = 3000;
                  "priority.session" = 3000;
                };
              };
            }
            {
              matches = [
                {
                  "node.name" = "~alsa_output.usb-DisplayLink.*";
                }
              ];
              actions = {
                update-props = {
                  "priority.driver" = 3500;
                  "priority.session" = 3500;
                };
              };
            }
          ];
        };
      };
    };
  };
}
