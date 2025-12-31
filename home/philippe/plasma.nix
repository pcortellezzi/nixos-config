{ inputs, pkgs, ... }:

{
  imports = [
    inputs.plasma-manager.homeModules.plasma-manager
  ];

  home.packages = with pkgs; [
    plasma-window-title-applet
    plasma-panel-colorizer
    krohnkite
  ];

  programs.plasma = {
    enable = true;

    # Thème sombre et style
    workspace = {
      lookAndFeel = "org.kde.breezedark.desktop";
      clickItemTo = "select";
      wallpaper = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/Patak/contents/images/1080x1920.png";
    };

    # Raccourcis clavier (Inspiré des WM Tiling / Niri)
    shortcuts = {
      "kwin" = {
        "Window Close" = "Meta+Q";
        "Window Maximize" = "Meta+F";
        "Window Minimize" = "Meta+kp_minus";
        "Switch to Next Desktop" = "Meta+Right";
        "Switch to Previous Desktop" = "Meta+Left";
        "Overview" = "Meta+A";
      };
      "org.kde.krunner.desktop"."_launch" = ["Alt+Space" "Meta+Space" "Search"];
      "services/org.kde.plasma.emojier.desktop"."_launch" = "Meta+.";
      "services/org.kde.spectacle.desktop"."_launch" = "Print";
      "org.kde.konsole.desktop"."_launch" = "Meta+Return";
    };

    # Configuration des panneaux (Style taj-ny)
    panels = [
      {
        height = 36;
        location = "top";
        floating = false;
        widgets = [
          {
            kickoff.icon = "nix-snowflake-white";
          }
          {
            name = "org.kde.windowtitle";
            config.General = {
              capitalFont = false;
              filterActivityInfo = false;
              useActivityIcon = false;
            };
          }
          "org.kde.plasma.appmenu"
          "org.kde.plasma.panelspacer"
          {
            systemTray.items = {
              shown = [
                "org.kde.plasma.battery"
                "org.kde.plasma.volume"
                "org.kde.plasma.networkmanagement"
              ];
              hidden = [
                "org.kde.plasma.clipboard"
              ];
            };
          }
          {
            digitalClock = {
              date.enable = true;
              time.showSeconds = "always";
            };
          }
          {
            name = "luisbocanegra.panel.colorizer";
            config.General = {
              colorMode = "1";
              colorModeTheme = "9";
              enableCustomPadding = "true";
              fgColorMode = "1";
              fgContrastFixEnabled = "false";
              fgLightness = "0.55";
              hideWidget = "true";
              marginRules = "org.kde.plasma.kickoff,1,0|org.kde.windowtitle,1,0|plasmusic-toolbar,0,-15";
              panelPadding = "6";
              panelRealBgOpacity = "0.5";
              panelSpacing = "6";
              radius = "10";
              widgetBgEnabled = "false";
              widgetBgVMargin = "3";
            };
          }
        ];
      }
    ];

    # Configuration bas niveau (KWin, Plasma) via fichiers de config
    configFile = {
      "kwinrc" = {
        "ModifierOnlyShortcuts" = {
          "Meta" = "org.kde.krunner,org.kde.krunner,runCommand";
        };
        "org.kde.kdecoration2" = {
          "BorderSize" = "None";
          "ButtonsOnLeft" = "";
          "ButtonsOnRight" = "";
        };
        "Desktops" = {
          "Number" = 4;
          "Rows" = 1;
          "Name_1" = "I";
          "Name_2" = "II";
          "Name_3" = "III";
          "Name_4" = "IV";
        };
        "Windows" = {
            "RollOverDesktops" = true;
            "FocusPolicy" = "FocusFollowsMouse";
        };
        "Plugins" = {
           "blurEnabled" = false; # Désactivé au profit de forceblur
           "contrastEnabled" = true;
           "kwin4_effect_shapecornersEnabled" = true;
           "krohnkiteEnabled" = true;
           "forceblurEnabled" = true; # Activation de kwin-better-blur
        };
        "Script-krohnkite" = {
          "enableCustomBorders" = false;
          "screenGapBottom" = 10;
          "screenGapLeft" = 10;
          "screenGapRight" = 10;
          "screenGapTop" = 10;
          "tileLayoutGap" = 10;
        };
      };
      
      "klaunchrc"."FeedbackStyle"."BusyCursor" = false;
      "kdeglobals"."KDE" = {
        "AnimationDurationFactor" = "0.7";
        "widgetStyle" = "Darkly";
      };

      "darklyrc" = {
        "Common" = {
          "CornerRadius" = 8;
        };
        "Style" = {
          "AdjustToDarkThemes" = true;
          "DolphinSidebarOpacity" = 50;
          "MenuOpacity" = 80;
          "TabBGColor" = "0,0,0,50";
          "TabUseHighlightColor" = true;
        };
      };
      
      # Configuration de kwin-better-blur
      "kwinbetterblurrc" = {
        "WindowRules/Global/Properties" = {
          "BlurStrength" = 9;
          "CornerAntialiasing" = 1;
          "WindowOpacityAffectsBlur" = false;
        };
        "WindowRules/ForceBlur/Conditions/0" = {
          "WindowClass" = "konsole|yakuake"; # Applications à flouter
          "WindowType" = "Dialog Normal Menu Toolbar Tooltip Utility";
        };
        "WindowRules/ForceBlur/Conditions/1" = {
          "Negate" = "WindowType";
          "WindowClass" = "firefox";
          "WindowType" = "Menu";
        };
        "WindowRules/ForceBlur/Properties" = {
          "BlurContent" = true;
          "BlurDecorations" = true;
        };
      };
    };
  };
}