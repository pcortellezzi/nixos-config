{ inputs, pkgs, ... }:

{
  imports = [
    inputs.plasma-manager.homeManagerModules.plasma-manager
  ];

  programs.plasma = {
    enable = true;

    # Thème sombre et style
    workspace = {
      lookAndFeel = "org.kde.breezedark.desktop";
      clickItemTo = "select";
    };

    # Raccourcis clavier (Inspiré des WM Tiling / Niri)
    shortcuts = {
      "kwin" = {
        "Window Close" = "Meta+Q";
        "Window Maximize" = "Meta+F";
        "Window Minimize" = "Meta+kp_minus";
        "Switch to Next Desktop" = "Meta+Right";
        "Switch to Previous Desktop" = "Meta+Left";
        "Overview" = "Meta+A"; # Vue d'ensemble style Gnome/DMS
      };
      "org.kde.krunner.desktop"."_launch" = ["Alt+Space" "Meta+Space" "Search"];
      "services/org.kde.plasma.emojier.desktop"."_launch" = "Meta+.";
      "services/org.kde.spectacle.desktop"."_launch" = "Print";
      # Lancement terminal (Meta+Return) - nécessite de savoir quel terminal est utilisé
      # Nous supposons ici Alacritty ou le terminal par défaut configuré ailleurs, 
      # sinon Konsole par défaut.
      "org.kde.konsole.desktop"."_launch" = "Meta+Return";
    };

    # Configuration des panneaux (Barre flottante style DMS/Mobile)
    panels = [
      {
        location = "top";
        floating = true;
        height = 44;
        screen = 0;
        widgets = [
          {
            name = "org.kde.plasma.kickoff";
            config = {
              General = {
                icon = "nix-snowflake-white";
                alphaSort = true;
              };
            };
          }
          "org.kde.plasma.pager" # Indicateur de bureaux
          "org.kde.plasma.icontasks" # Liste des tâches (icônes uniquement)
          "org.kde.plasma.marginsseparator"
          "org.kde.plasma.systemtray"
          "org.kde.plasma.digitalclock"
        ];
      }
    ];

    # Configuration bas niveau (KWin, Plasma) via fichiers de config
    configFile = {
      "kwinrc" = {
        # Appui sur Meta seul pour KRunner
        "ModifierOnlyShortcuts" = {
          "Meta" = "org.kde.krunner,org.kde.krunner,runCommand";
        };
        # Désactiver les bordures de fenêtres pour un look "Tiling" propre
        "org.kde.kdecoration2" = {
          "BorderSize" = "None";
          "ButtonsOnLeft" = ""; # Pas de boutons
          "ButtonsOnRight" = ""; # Pas de boutons
        };
        # Bureaux virtuels
        "Desktops" = {
          "Number" = 4;
          "Rows" = 1; # Disposition horizontale (comme Niri)
          "Name_1" = "I";
          "Name_2" = "II";
          "Name_3" = "III";
          "Name_4" = "IV";
        };
        # Comportement des fenêtres
        "Windows" = {
            "RollOverDesktops" = true; # Boucler du dernier au premier bureau
            "FocusPolicy" = "FocusFollowsMouse"; # Focus suit la souris (classique Tiling)
        };
      };
      
      # Activer le tiling natif de Plasma 6
      "kwinrc"."Plugins"."bismuthEnabled" = false; # On s'assure que bismuth est off si jamais
      "kwinrc"."Script-polonium"."Enabled" = false;
    };
  };
}