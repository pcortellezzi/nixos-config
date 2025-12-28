{
  pkgs, inputs, ...
}:
let
  inherit (inputs) dms danksearch;
in
{
  programs.dms-shell = {
    enable = true;
    package = dms.packages.${pkgs.stdenv.hostPlatform.system}.default;

    # Core features
    enableSystemMonitoring = true;
    enableClipboard = true;
    enableVPN = true;
    enableDynamicTheming = true;
    enableAudioWavelength = true;
    enableCalendarEvents = true;
  };

  programs.dsearch = {
    enable = true;
    package = danksearch.packages.${pkgs.stdenv.hostPlatform.system}.default;

    systemd = {
      enable = true;
      target = "graphical-session.target";  # Only start in graphical sessions
    };
  };

  programs.niri = {
    enable = true;
    useNautilus = true;

    settings = {
      outputs = {
        "LG Electronics LG HDR WQHD 204NTHMB9585" = {
          mode = {
            width = 3440;
            height = 1440;
            refresh = 100.0;
          };
          position = {
            x = 0;
            y = 0;
          };
          scale = 1.0;
        };
       "LG Electronics LG HDR WQHD 204NTABB9600" = {
          mode = {
            width = 3440;
            height = 1440;
            refresh = 100.0;
          };
          position = {
            x = 0;
            y = 1440;
          };
          scale = 1.0;
        };
       "Iiyama North America PL2730Q 1219930721568" = {
          mode = {
            width = 2560;
            height = 1440;
            refresh = 60.0;
          };
          position = {
            x = 3440;
            y = 0;
          };
          scale = 1.0;
        };
       "eDP-1" = {
          mode = {
            width = 2880;
            height = 1620;
            refresh = 120.0;
          };
          position = {
            x = 4880;
            y = 1234;
          };
          scale = 1.75;
        };
      };
    };
  };

  environment.systemPackages = with pkgs; [
    nautilus
    alacritty
    fuzzel
    swaylock
    brightnessctl
  ];
}
