{ inputs, pkgs, ... }:

{
  imports = [
    inputs.plasma-manager.homeModules.plasma-manager
  ];

  home.packages = with pkgs; [
    kde-rounded-corners
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
          "BorderSize" = "Large";
          "ButtonsOnLeft" = "M";
          "ButtonsOnRight" = "IAX";
          "library" = "org.kde.kwin.breeze";
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
           "krohnkiteEnabled" = false;
        };
        # Activer "disable" outline mais désactiver round sur fenêtres tuilées
        # pour éviter de cacher le contour actif en mode tiling
        "Round-Corners" = {
          # Fenêtre active : contour bleu 2px (comme i3/sway)
          "OutlineThickness" = 2;
          "OutlineColor" = "61,174,233";
          "ActiveOutlineAlpha" = 255;
          # Fenêtres inactives : contour gris subtil 1px
          "InactiveOutlineThickness" = 1;
          "InactiveOutlineColor" = "100,100,100";
          "InactiveOutlineAlpha" = 150;
          # Contour visible en mode tiling
          "DisableOutlineTile" = false;
          "DisableRoundTile" = true;
          # Pas de contour en maximisé / plein écran / fullscreen
          "DisableOutlineMaximize" = true;
          "DisableOutlineFullScreen" = true;
          # Rayon des coins et animation
          "Size" = 10;
          "InactiveCornerRadius" = 10;
          "AnimationDuration" = 200;
        };
      };
      
      "klaunchrc"."FeedbackStyle"."BusyCursor" = false;
      "kdeglobals"."KDE"."AnimationDurationFactor" = "0.7";

      # Désactiver l'outline Breeze natif (pour éviter conflit avec Round-Corners)
      "breezerc"."Common"."OutlineIntensity" = "OutlineOff";

      "kcminputrc" = {
        "Mouse" = {
          "NaturalScroll" = true;
        };
      };
    };

    input.keyboard.numlockOnStartup = "on";
  };
}