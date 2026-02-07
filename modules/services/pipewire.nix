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
        "10-disable-reserve" = {
          "monitor.alsa.rules" = [
            {
              matches = [
                {
                  "device.name" = "~alsa_card.*";
                }
              ];
              actions = {
                update-props = {
                  "api.alsa.reserve" = false;
                  "api.acp.auto-port" = false;
                  "api.acp.auto-profile" = false;
                  "node.suspend-on-idle" = false;
                };
              };
            }
            {
              matches = [
                {
                  "device.name" = "~alsa_card.usb-DisplayLink.*";
                }
              ];
              actions = {
                update-props = {
                  "api.alsa.use-acp" = false;
                  "api.alsa.use-ucm" = false;
                  "priority.driver" = 1050;
                  "priority.session" = 1050;
                };
              };
            }
          ];
        };
      };
    };
  };
}
