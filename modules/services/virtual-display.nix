{ config, lib, pkgs, ... }:

let
  cfg = config.my.virtual-display;
in
{
  options.my.virtual-display = {
    enable = lib.mkEnableOption "auto-create virtual display at login" // { default = false; };

    name = lib.mkOption {
      type = lib.types.str;
      default = "Virtual-1";
      description = "Name of the virtual output as seen by KWin/kscreen";
    };

    width = lib.mkOption {
      type = lib.types.int;
      default = 1920;
      description = "Virtual display width in pixels";
    };

    height = lib.mkOption {
      type = lib.types.int;
      default = 1080;
      description = "Virtual display height in pixels";
    };

    refresh = lib.mkOption {
      type = lib.types.int;
      default = 60;
      description = "Virtual display refresh rate in Hz";
    };

    primary = lib.mkOption {
      type = lib.types.str;
      default = "";
      example = "eDP-1";
      description = "Primary output name. Auto-detected if empty.";
    };

    position = lib.mkOption {
      type = lib.types.enum [ "leftOf" "rightOf" "above" "below" "sameAs" ];
      default = "rightOf";
      description = "Position relative to primary display";
    };
  };

  config = lib.mkMerge [
    # Packages + scripts always available (no rebuild needed to toggle)
    {
      environment.systemPackages = with pkgs; [
        kdePackages.libkscreen
        kdePackages.qttools
        (pkgs.callPackage ../../modules/plasmoids/virtual-display-toggle {})
      ];
    }

    # Systemd user service (manual start/stop: systemctl --user start/stop virtual-display)
    {
      systemd.user.services.virtual-display = {
        description = "Virtual Display for Extended Desktop";
        after = [ "graphical-session.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = let
            createScript = pkgs.writeShellScriptBin "kde-virtual-display-create" ''
              set -euo pipefail

              NAME="${cfg.name}"
              W=${toString cfg.width}
              H=${toString cfg.height}
              R=${toString cfg.refresh}
              POS="${cfg.position}"
              PRIMARY="${cfg.primary}"

              CREATE_OK=false
              if ${pkgs.dbus}/bin/dbus-send --session \
                --dest=org.kde.KWin --type=method_call --print-reply \
                /VirtualOutputManager \
                org.kde.kwin.VirtualOutputManager.createOutput \
                string:"$NAME" int32:$W int32:$H double:1.0 &>/dev/null; then
                CREATE_OK=true
              elif ${lib.getBin pkgs.kdePackages.qttools}/bin/qdbus \
                org.kde.KWin /VirtualOutputManager \
                org.kde.kwin.VirtualOutputManager.createOutput \
                "$NAME" $W $H 1.0 &>/dev/null; then
                CREATE_OK=true
              fi

              if [ "$CREATE_OK" != "true" ]; then
                echo "ERROR: Could not create virtual output via KWin D-Bus."
                echo "Make sure KWin is running (KDE Plasma 6 Wayland session)."
                exit 1
              fi

              sleep 0.5

              KSCREEN="${lib.getBin pkgs.kdePackages.libkscreen}/bin/kscreen-doctor"
              $KSCREEN "output.$NAME.enable" 2>/dev/null || true
              $KSCREEN "output.$NAME.mode.${toString cfg.width}x${toString cfg.height}@${toString cfg.refresh}" 2>/dev/null || true

              if [ -z "$PRIMARY" ]; then
                PRIMARY=$($KSCREEN -o 2>/dev/null | grep "enabled" | head -1 | cut -d' ' -f2 || echo "")
                if [ -z "$PRIMARY" ]; then
                  PRIMARY="eDP-1"
                fi
              fi

              $KSCREEN "output.$NAME.position.$POS.$PRIMARY" 2>/dev/null || true

              echo "Virtual display $NAME created ($W x $H, $POS $PRIMARY)"
            '';
          in "${createScript}/bin/kde-virtual-display-create";
          ExecStop = let
            removeScript = pkgs.writeShellScriptBin "kde-virtual-display-remove" ''
              NAME="${cfg.name}"
              if ${pkgs.dbus}/bin/dbus-send --session \
                --dest=org.kde.KWin --type=method_call --print-reply \
                /VirtualOutputManager \
                org.kde.kwin.VirtualOutputManager.removeOutput \
                string:"$NAME" &>/dev/null; then
                echo "Virtual display $NAME removed"
              elif ${lib.getBin pkgs.kdePackages.qttools}/bin/qdbus \
                org.kde.KWin /VirtualOutputManager \
                org.kde.kwin.VirtualOutputManager.removeOutput \
                "$NAME" &>/dev/null; then
                echo "Virtual display $NAME removed"
              else
                echo "Note: Virtual display may have been cleaned up by KWin already"
              fi
            '';
          in "${removeScript}/bin/kde-virtual-display-remove";
        };
      };
    }

    # Auto-start toggle (enable = true → auto-create at login)
    (lib.mkIf cfg.enable {
      systemd.user.services.virtual-display.wantedBy = [ "graphical-session.target" ];
    })
  ];
}
