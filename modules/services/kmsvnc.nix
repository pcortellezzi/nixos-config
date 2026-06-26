{ config, lib, pkgs, ... }:

let
  startScript = pkgs.writeShellScriptBin "kmsvnc-start" ''
    set -euo pipefail

    # Find the DRM card with DP-1 connector (EDID-injected virtual display)
    DEVICE="/dev/dri/card0"
    for d in /sys/class/drm/card*; do
      # Match DP-1 but not eDP-1
      connector_list="$(ls "$d-"* 2>/dev/null)"
      if echo "$connector_list" | grep -q "-DP-1$" && ! echo "$connector_list" | grep -q "-eDP-1$"; then
        DEVICE="/dev/dri/$(basename $d)"
        break
      fi
    done

    echo "Starting kmsvnc on $DEVICE (DP-1 virtual display)"
    exec ${config.security.wrapperDir}/kmsvnc -d "$DEVICE" -i --fps 30 -p 5901
  '';
in
{
  environment.systemPackages = [ pkgs.kmsvnc ];

  networking.firewall.allowedTCPPorts = [ 5901 ];

  security.wrappers.kmsvnc = {
    owner = "root";
    group = "root";
    capabilities = "cap_setpcap,cap_sys_admin=p";
    source = "${pkgs.kmsvnc}/bin/kmsvnc";
  };

  systemd.user.services.kmsvnc = {
    description = "KMS VNC Server - AMD DP-1 virtual display";
    after = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${startScript}/bin/kmsvnc-start";
      Restart = "on-failure";
      RestartSec = "5";
    };
  };
}
