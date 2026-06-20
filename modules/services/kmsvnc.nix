{ config, lib, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.kmsvnc ];

  networking.firewall.allowedTCPPorts = [ 5901 ];

  systemd.user.services.kmsvnc = {
    description = "KMS VNC Server - Virtual-1 display";
    after = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.kmsvnc}/bin/kmsvnc -d /dev/dri/card2 -i --fps 30 -p 5901";
      Restart = "on-failure";
      RestartSec = "5";
    };
  };
}
