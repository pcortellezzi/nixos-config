{ pkgs, config, lib, ... }:

let
  # WORKAROUND: KDE Plasma 6 Wayland natural scrolling
  #
  # Le defilement naturel ne peut pas etre configure de maniere declarative
  # a cause de deux limitations upstream :
  #
  # 1. plasma-manager #576 (ouvert) : pas d'option generique pour definir
  #    naturalScroll sur tous les peripheriques sans connaitre leurs IDs
  #    https://github.com/nix-community/plasma-manager/issues/576
  #
  # 2. KDE Bug 513879 : KWin sous Wayland ignore kcminputrc pour la souris
  #    (inotify watch casse). Meme les changements manuels via GUI ne tiennent pas.
  #    https://bugs.kde.org/show_bug.cgi?id=513879
  #
  # 3. services.xserver.libinput.naturalScrolling est ecrase par KDE au demarrage
  #    https://github.com/NixOS/nixpkgs/issues/51875
  #
  # Solution : script autostart qui utilise l API D-Bus de KWin (methode
  # recommandee par les devs KDE) pour activer naturalScroll sur tous les
  # touchpads et souris au login.
  #
  # A SUPPRIMER quand les bugs KDE seront fixes ET que plasma-manager aura
  # une option generic all_touchpads/all_mice.

  ensureNaturalScroll = pkgs.writeShellScriptBin "ensure-natural-scroll" ''
    for i in $(seq 10); do
      qdbus org.kde.KWin /KWin >/dev/null 2>&1 && break
      sleep 0.5
    done
    QDBUS=$(command -v qdbus 2>/dev/null || command -v qdbus6 2>/dev/null)
    [ -z "$QDBUS" ] && exit 0
    for dev in $("$QDBUS" org.kde.KWin /KWin inputDevices 2>/dev/null); do
      type=$("$QDBUS" org.kde.KWin "$dev" org.kde.KWin.InputDevice.type 2>/dev/null)
      if [ "$type" = "Touchpad" ] || [ "$type" = "Pointer" ]; then
        "$QDBUS" org.kde.KWin "$dev" org.kde.KWin.InputDevice.naturalScroll true
      fi
    done
  '';
in
{
  programs.plasma = {
    enable = true;
    overrideConfig = true;

    workspace = {
      cursor = {
        theme = "breeze_cursors";
        size = 24;
      };
      theme = "breeze-dark";
      colorScheme = "BreezeDark";
      lookAndFeel = "org.kde.breezedark.desktop";
      iconTheme = "breeze-dark";
      widgetStyle = "breeze";
    };

    kwin = {
      virtualDesktops = {
        number = 4;
        rows = 2;
        names = [ "Web" "Dev" "Term" "Media" ];
      };
      borderlessMaximizedWindows = true;
      tiling = {
        padding = 4;
      };
      effects = {
        blur.enable = true;
        dimAdminMode.enable = true;
        dimInactive.enable = true;
        wobblyWindows.enable = false;
        minimization.animation = "magiclamp";
        desktopSwitching.animation = "slide";
        windowOpenClose.animation = "glide";
        snapHelper.enable = true;
      };
      nightLight = {
        enable = true;
        mode = "location";
        location = {
          latitude = "4.9";
          longitude = "-52.3";
        };
      };
    };



    panels = [
      {
        location = "top";
        height = 32;
        floating = true;
        hiding = "none";
        opacity = "adaptive";
        alignment = "center";
        widgets = [
          "org.kde.plasma.kickoff"
          "org.kde.plasma.pager"
          "org.kde.plasma.icontasks"
          "org.kde.plasma.panelspacer"
          {
            digitalClock = {
              calendar.firstDayOfWeek = "monday";
              date.enable = true;
              date.format = "longDate";
              time.format = "24h";
              time.showSeconds = "always";
            };
          }
          {
            digitalClock = {
              time.format = "24h";
              time.showSeconds = "always";
              timeZone.selected = [ "America/New_York" ];
              timeZone.lastSelected = "America/New_York";
              timeZone.format = "city";
              settings.Appearance.showDate = false;
            };
          }
          {
            digitalClock = {
              time.format = "24h";
              time.showSeconds = "always";
              timeZone.selected = [ "Europe/London" ];
              timeZone.lastSelected = "Europe/London";
              timeZone.format = "city";
              settings.Appearance.showDate = false;
            };
          }
          {
            digitalClock = {
              time.format = "24h";
              time.showSeconds = "always";
              timeZone.selected = [ "Europe/Paris" ];
              timeZone.lastSelected = "Europe/Paris";
              timeZone.format = "city";
              settings.Appearance.showDate = false;
            };
          }
          "org.kde.plasma.systemtray"
          "org.kde.plasma.battery"
        ];
      }
    ];

    shortcuts = {
      "kwin"."Switch to Desktop 1" = "Ctrl+F1";
      "kwin"."Switch to Desktop 2" = "Ctrl+F2";
      "kwin"."Switch to Desktop 3" = "Ctrl+F3";
      "kwin"."Switch to Desktop 4" = "Ctrl+F4";
      "kwin"."Quick Tile Window to Left" = "Meta+Left";
      "kwin"."Quick Tile Window to Right" = "Meta+Right";
      "kwin"."Quick Tile Window to Top" = "Meta+Up";
      "kwin"."Quick Tile Window to Bottom" = "Meta+Down";
      "kwin"."Maximize Window" = "Meta+Shift+Up";
      "kwin"."Window Close" = "Alt+F4";
      "kwin"."Kill Window" = "Ctrl+Alt+Escape";
      "kwin"."Window Toggle Floating" = "Meta+T";
      "kwin"."Switch to Window Above" = "Meta+Alt+Up";
      "kwin"."Switch to Window Below" = "Meta+Alt+Down";
      "kwin"."Switch to Window Left" = "Meta+Alt+Left";
      "kwin"."Switch to Window Right" = "Meta+Alt+Right";
      "kwin"."Show Desktop Grid" = "Meta+F8";
      "kwin"."Expose" = "Meta+F9";
      "ksmserver"."Lock Session" = "Meta+L";
      "krunner"."RunCommand" = "Alt+Space";
      "krunner"."RunClipboard" = "Alt+Shift+Space";
      "org_kde_pi_plasma_clock"."screenshots" = "Print";
      "org_kde_pi_plasma_clock"."screenshotsOfArea" = "Meta+Shift+S";
    };

    configFile."kdeglobals"."General" = {
      TerminalApplication = "konsole";
      TerminalService = "konsole.desktop";
    };
    configFile."kdeglobals"."Locale" = {
      Language = "fr_FR";
      Country = "FR";
      Use12hFormat = false;
    };

    configFile."kwinrc"."Windows" = {
      FocusPolicy = "FollowsMouse";
    };

    configFile."konsolerc"."Desktop Entry" = {
      DefaultProfile = "Shell.profile";
    };

    configFile."plasmarc"."Wallpaper" = {
      defaultWallpaperPlugin = "org.kde.image";
    };

    configFile."kiorc"."Confirmations" = {
      ConfirmDelete = false;
      ConfirmTrash = false;
    };

    configFile."dolphinrc"."General" = {
      RememberOpenedTabs = false;
      ShowFullPath = true;
      Version = 6;
    };
    configFile."dolphinrc"."KFileDialog Settings" = {
      ShowSpeedDisplay = true;
    };

    configFile."krunnerrc"."General" = {
      FreeFloating = true;
      ActivateOnMouseOver = false;
    };

    configFile."kcminputrc"."Keyboard" = {
      RepeatDelay = 250;
      RepeatRate = 40;
      NumLock = 0;
    };
  };
  home.packages = [
    ensureNaturalScroll
  ];

  # Autostart KDE (phase 2 = apres KWin) pour appliquer le workaround a chaque login
  xdg.configFile."autostart/ensure-natural-scroll.desktop" = {
    text = ''
      [Desktop Entry]
      Type=Application
      Name=Ensure Natural Scrolling
      Exec=${ensureNaturalScroll}/bin/ensure-natural-scroll
      X-KDE-autostart-phase=2
      Terminal=false
    '';
  };
}
