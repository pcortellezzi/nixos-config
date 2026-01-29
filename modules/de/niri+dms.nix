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
    enableVPN = true;
    enableDynamicTheming = true;
    enableAudioWavelength = true;
    enableCalendarEvents = true;
  };

  programs.niri = {
    enable = true;
    useNautilus = true;
  };

  systemd.user.services.dms = {
    wantedBy = pkgs.lib.mkForce [ "niri.service" ];
    after = pkgs.lib.mkForce [ "niri.service" ];
    bindsTo = pkgs.lib.mkForce [ "niri.service" ];
    partOf = pkgs.lib.mkForce [ ];
  };
}
