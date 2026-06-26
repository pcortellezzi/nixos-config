{ config, lib, pkgs, ... }:

let
  startScript = pkgs.writeShellScriptBin "kmsvnc-start" ''
    set -euo pipefail

    # Find the DRM card with DP-1 connector (EDID-injected virtual display)
    DEVICE="/dev/dri/card0"
    for conn in /sys/class/drm/card*-*/; do
      conn_name="$(basename "$conn")"
      if [[ "$conn_name" =~ -DP-1$ ]] && [[ ! "$conn_name" =~ -eDP-1$ ]]; then
        DEVICE="/dev/dri/$(echo "$conn_name" | cut -d- -f1)"
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
