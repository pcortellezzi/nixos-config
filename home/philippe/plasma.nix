{ pkgs, config, lib, ... }:

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

    configFile."kcminputrc"."Libinput" = {
      NaturalScroll = true;
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
            };
          }
          "org.kde.plasma.panelspacer"
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
}
