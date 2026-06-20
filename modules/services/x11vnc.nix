{ config, lib, pkgs, ... }:

let
  startScript = pkgs.writeShellScriptBin "x11vnc-start" ''
    set -euo pipefail

    MODE="1920x1080_60"
    MODELINE="173.00 1920 2048 2248 2576 1080 1083 1088 1120 -hsync +vsync"
    PORT="5902"

    # Créer le mode si pas déjà fait
    ${pkgs.xorg.xrandr}/bin/xrandr --newmode "$MODE" $MODELINE 2>/dev/null || true

    # Ajouter à un port déconnecté
    PORT_NAME=""
    for p in DisplayPort-0 DisplayPort-1 HDMI-1-0; do
      if ${pkgs.xorg.xrandr}/bin/xrandr --addmode "$p" "$MODE" 2>/dev/null; then
        PORT_NAME="$p"
        break
      fi
    done

    if [ -z "$PORT_NAME" ]; then
      echo "Aucun port disponible pour l'écran virtuel"
      exit 1
    fi

    # Activer l'écran virtuel à droite de l'écran principal
    ${pkgs.xorg.xrandr}/bin/xrandr --output "$PORT_NAME" --mode "$MODE" --right-of eDP --pos 1920x0

    # Lancer x11vnc sur la zone de l'écran virtuel uniquement
    exec ${pkgs.x11vnc}/bin/x11vnc \
      -clip 1920x1080+1920+0 \
      -forever \
      -nocursorshape \
      -cursor arrow \
      -noxdamage \
      -repeat \
      -rfbport "$PORT"
  '';
in
{
  environment.systemPackages = [ pkgs.x11vnc ];

  networking.firewall.allowedTCPPorts = [ 5902 ];

  systemd.user.services.x11vnc = {
    description = "x11vnc - Virtual-1 display with cursor";
    after = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${startScript}/bin/x11vnc-start";
      Restart = "on-failure";
      RestartSec = "5";
    };
  };
}
