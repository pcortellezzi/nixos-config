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
  };

  security.pam.services.swaylock = {};
}
