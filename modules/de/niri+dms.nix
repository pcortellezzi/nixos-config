{
  pkgs, inputs, ...
}:
let
  inherit (inputs) dms danksearch;
in
{
  imports = [
    ../services/keyd.nix
  ];

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

  programs.niri = {
    enable = true;
    useNautilus = true;
  };

  security.pam.services.swaylock = {};
}
