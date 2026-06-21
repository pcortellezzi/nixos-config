{ config, lib, pkgs, ... }:

let
  startScript = pkgs.writeShellScriptBin "kmsvnc-start" ''
    set -euo pipefail

    # Find the VKMS DRM card (it has a Virtual-1 connector)
    VKMS_CARD="card0"
    for d in /sys/class/drm/card*; do
      if ls "$d-"* 2>/dev/null | grep -q Virtual-1; then
        VKMS_CARD="$(basename $d)"
        break
      fi
    done

    DEVICE="/dev/dri/$VKMS_CARD"
    echo "Starting kmsvnc on $DEVICE (Virtual-1)"
    exec ${config.security.wrapperDir}/kmsvnc -d "$DEVICE" -c -i --fps 30 -p 5901
  '';
in
{
  environment.systemPackages = [ pkgs.kmsvnc ];

  networking.firewall.allowedTCPPorts = [ 5901 ];

  security.wrappers.kmsvnc = {
    owner = "root";
    group = "root";
    capabilities = "cap_sys_admin+p";
    source = "${pkgs.kmsvnc}/bin/kmsvnc";
  };

  systemd.user.services.kmsvnc = {
    description = "KMS VNC Server - Virtual-1 display";
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
