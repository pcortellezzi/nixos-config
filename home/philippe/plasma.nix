{ inputs, pkgs, ... }:

{
  imports = [
    inputs.plasma-manager.homeModules.plasma-manager
  ];

  home.packages = with pkgs; [
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
          "BorderSize" = "Normal";
          "ButtonsOnLeft" = "M";
          "ButtonsOnRight" = "IAX";
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
           "contrastEnabled" = true;
           "kwin4_effect_shapecornersEnabled" = true;
           "krohnkiteEnabled" = true;
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
      "kdeglobals"."KDE"."AnimationDurationFactor" = "0.7";

      "kcminputrc" = {
        "Mouse" = {
          "NaturalScroll" = true;
        };
      };
    };

    input.keyboard.numlockOnStartup = "on";
  };
}