{
  pkgs, lib, inputs, ...
}:
let
  inherit (inputs) dms danksearch;
in
{
  imports = [
    ../services/keyd.nix
  ];

  # Prevent keyd from auto-starting at boot — it will be managed by keyd-session below
  systemd.services.keyd.wantedBy = lib.mkForce [ ];

  # User service that starts/stops the system keyd service with niri
  systemd.user.services.keyd-session = {
    description = "Manage keyd for niri session";
    wantedBy = [ "niri.service" ];
    after = [ "niri.service" ];
    bindsTo = [ "niri.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.systemd}/bin/systemctl start keyd";
      ExecStop = "${pkgs.systemd}/bin/systemctl stop keyd";
    };
  };

  # Allow user to start/stop keyd without password via polkit
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "org.freedesktop.systemd1.manage-units" &&
          action.lookup("unit") == "keyd.service" &&
          subject.isInGroup("users")) {
        return polkit.Result.YES;
      }
    });
  '';

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
    wantedBy = lib.mkForce [ "niri.service" ];
    after = lib.mkForce [ "niri.service" ];
    bindsTo = lib.mkForce [ "niri.service" ];
    partOf = lib.mkForce [ ];
  };
}
