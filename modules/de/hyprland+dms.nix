{
  pkgs, lib, inputs, ...
}:
let
  inherit (inputs) dms;
in
{
  programs.hyprland.enable = true;

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

  systemd.user.services.dms = {
    wantedBy = lib.mkForce [ "hyprland-session.target" ];
    after = lib.mkForce [ "hyprland-session.target" ];
    bindsTo = lib.mkForce [ "hyprland-session.target" ];
    partOf = lib.mkForce [ ];
  };
}
