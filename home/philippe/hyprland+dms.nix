{ config, pkgs, inputs, ... }:

let
  inherit (inputs) danksearch dms;
in
{
  imports = [
    danksearch.homeModules.default
    dms.homeModules.dank-material-shell
  ];

  home.packages = with pkgs; [
    alacritty
    brightnessctl
    nautilus
    cliphist
    wl-clipboard
    rbw
    jq
    inotify-tools
    bc
    libqalculate
    adw-gtk3
    grim
    slurp
  ];

  programs.dank-material-shell = {
    enable = true;

    settings = {
      gtkThemingEnabled = true;
      qtThemingEnabled = true;
    };

    plugins = {
      qalculate = {
        enable = true;
        src = pkgs.fetchzip {
          url = "https://github.com/pcortellezzi/dms-plugins/releases/download/qalculate-v1.1.0/qalculate.zip";
          sha256 = "sha256-cDDoiLH4Je/fTGHbitK9pU+SHeGIjaAXhwU7rtxxH6A=";
        };
      };

      powermenu = {
        enable = true;
        src = pkgs.fetchzip {
          url = "https://github.com/pcortellezzi/dms-plugins/releases/download/powermenu-v1.1.0/powermenu.zip";
          sha256 = "sha256-viGj3outMQaFu3YMOV5+sODr+ysGiFryONmpslC743A=";
        };
      };

      webSearch = {
        enable = true;
        src = pkgs.fetchFromGitHub {
          owner = "devnullvoid";
          repo = "dms-web-search";
          rev = "main";
          sha256 = "sha256-mKbmROijhYhy/IPbVxYbKyggXesqVGnS/AfAEyeQVhg=";
        };
      };

      commandRunner = {
        enable = true;
        src = pkgs.fetchFromGitHub {
          owner = "devnullvoid";
          repo = "dms-command-runner";
          rev = "main";
          sha256 = "sha256-tXqDRVp1VhyD1WylW83mO4aYFmVg/NV6Z/toHmb5Tn8=";
        };
      };

      nixMonitor = {
        enable = true;
        src = pkgs.fetchFromGitHub {
          owner = "antonjah";
          repo = "nix-monitor";
          rev = "v1.0.3";
          sha256 = "sha256-biRc7ESKzPK5Ueus1xjVT8OXCHar3+Qi+Osv/++A+Ls=";
        };
      };
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    plugins = [ pkgs.hyprspace ];
    settings = {
      # Monitors
      monitor = [
        "desc:LG Electronics LG HDR WQHD 204NTHMB9585, 3440x1440@100, 0x0, 1"
        "desc:LG Electronics LG HDR WQHD 204NTABB9600, 3440x1440@100, 0x1440, 1"
        "desc:Iiyama North America PL2730Q 1219930721568, 2560x1440@60, 3440x0, 1, transform, 3"
        "eDP-1, 2880x1620@120, 4880x2100, 1.80"
      ];

      # Input
      input = {
        kb_layout = "fr";
        numlock_by_default = true;
        touchpad = {
          tap-to-click = true;
          natural_scroll = true;
        };
      };

      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        layout = "dwindle";
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      decoration = {
        rounding = 10;
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
        };
        shadow = {
          enabled = false;
        };
      };

      animations.enabled = true;

      plugin = {
        overview = {
          centerAligned = true;
          autoDrag = true;
          exitOnClick = true;
          switchOnDrop = true;
          exitOnSwitch = true;
        };
      };

      exec-once = [ "dms run --session" ];

      cursor = {
        no_hardware_cursors = true;
      };

      xwayland = {
        force_zero_scaling = true;
      };

      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo = true;
      };


      # Window rules (v3 syntax: match before comma, effect after)
      windowrule = [
        "match:class ^(org\\.wezfurlong\\.wezterm)$, float on"
        "match:class firefox match:title ^(Picture-in-Picture)$, float on"
        "match:class firefox match:title ^(Picture-in-Picture)$, pin on"
      ];

      # Keybindings
      bind = [
        # Terminal
        "SUPER, T, exec, alacritty"

        # Window management
        "SUPER, Q, killactive"
        "SUPER, F, fullscreen, 1"  # maximize
        "SUPER SHIFT, F, fullscreen, 0"  # true fullscreen
        "SUPER, V, togglefloating"

        # Focus movement
        "SUPER, left, movefocus, l"
        "SUPER, down, movefocus, d"
        "SUPER, up, movefocus, u"
        "SUPER, right, movefocus, r"
        "SUPER, H, movefocus, l"
        "SUPER, J, movefocus, d"
        "SUPER, K, movefocus, u"
        "SUPER, L, movefocus, r"

        # Overview & window cycling
        "SUPER, Tab, overview:toggle"
        "ALT, Tab, movefocus, r"
        "ALT SHIFT, Tab, movefocus, l"

        # Move windows
        "SUPER CTRL, left, movewindow, l"
        "SUPER CTRL, down, movewindow, d"
        "SUPER CTRL, up, movewindow, u"
        "SUPER CTRL, right, movewindow, r"
        "SUPER CTRL, H, movewindow, l"
        "SUPER CTRL, J, movewindow, d"
        "SUPER CTRL, K, movewindow, u"
        "SUPER CTRL, L, movewindow, r"

        # Focus monitor
        "SUPER SHIFT, left, focusmonitor, l"
        "SUPER SHIFT, down, focusmonitor, d"
        "SUPER SHIFT, up, focusmonitor, u"
        "SUPER SHIFT, right, focusmonitor, r"
        "SUPER SHIFT, H, focusmonitor, l"
        "SUPER SHIFT, J, focusmonitor, d"
        "SUPER SHIFT, K, focusmonitor, u"
        "SUPER SHIFT, L, focusmonitor, r"

        # Move window to monitor
        "SUPER CTRL SHIFT, left, movewindow, mon:l"
        "SUPER CTRL SHIFT, down, movewindow, mon:d"
        "SUPER CTRL SHIFT, up, movewindow, mon:u"
        "SUPER CTRL SHIFT, right, movewindow, mon:r"
        "SUPER CTRL SHIFT, H, movewindow, mon:l"
        "SUPER CTRL SHIFT, J, movewindow, mon:d"
        "SUPER CTRL SHIFT, K, movewindow, mon:u"
        "SUPER CTRL SHIFT, L, movewindow, mon:r"

        # Workspaces (AZERTY: & é " ' ( - è _ ç)
        "SUPER, ampersand, workspace, 1"
        "SUPER, eacute, workspace, 2"
        "SUPER, quotedbl, workspace, 3"
        "SUPER, apostrophe, workspace, 4"
        "SUPER, parenleft, workspace, 5"
        "SUPER, minus, workspace, 6"
        "SUPER, egrave, workspace, 7"
        "SUPER, underscore, workspace, 8"
        "SUPER, ccedilla, workspace, 9"

        # Move window to workspace
        "SUPER CTRL, ampersand, movetoworkspace, 1"
        "SUPER CTRL, eacute, movetoworkspace, 2"
        "SUPER CTRL, quotedbl, movetoworkspace, 3"
        "SUPER CTRL, apostrophe, movetoworkspace, 4"
        "SUPER CTRL, parenleft, movetoworkspace, 5"
        "SUPER CTRL, minus, movetoworkspace, 6"
        "SUPER CTRL, egrave, movetoworkspace, 7"
        "SUPER CTRL, underscore, movetoworkspace, 8"
        "SUPER CTRL, ccedilla, movetoworkspace, 9"

        # Workspace navigation
        "SUPER, Page_Down, workspace, m+1"
        "SUPER, Page_Up, workspace, m-1"
        "SUPER, U, workspace, m+1"
        "SUPER, I, workspace, m-1"
        "SUPER CTRL, Page_Down, movetoworkspace, m+1"
        "SUPER CTRL, Page_Up, movetoworkspace, m-1"
        "SUPER CTRL, U, movetoworkspace, m+1"
        "SUPER CTRL, I, movetoworkspace, m-1"

        # Resize
        "SUPER, parenright, resizeactive, -10% 0"
        "SUPER, equal, resizeactive, 10% 0"
        "SUPER SHIFT, parenright, resizeactive, 0 -10%"
        "SUPER SHIFT, equal, resizeactive, 0 10%"

        # Misc
        "SUPER, C, centerwindow"
        "CTRL ALT, Delete, exit"

        # Screenshot — zone selection
        ", Print, exec, grim -g \"$(slurp)\" ~/Images/Screenshots/$(date +'%Y-%m-%d_%H-%M-%S').png"
        "SUPER SHIFT, S, exec, grim -g \"$(slurp)\" ~/Images/Screenshots/$(date +'%Y-%m-%d_%H-%M-%S').png"
        # Screenshot — full screen
        "CTRL, Print, exec, grim ~/Images/Screenshots/$(date +'%Y-%m-%d_%H-%M-%S').png"
        "CTRL SUPER SHIFT, S, exec, grim ~/Images/Screenshots/$(date +'%Y-%m-%d_%H-%M-%S').png"
        # Screenshot — active window
        "ALT, Print, exec, grim -g \"$(hyprctl -j activewindow | jq -r '.at[0],.at[1],.size[0],.size[1]' | tr '\\n' ' ' | awk '{printf \"%d,%d %dx%d\",$1,$2,$3,$4}')\" ~/Images/Screenshots/$(date +'%Y-%m-%d_%H-%M-%S').png"
        "ALT SUPER SHIFT, S, exec, grim -g \"$(hyprctl -j activewindow | jq -r '.at[0],.at[1],.size[0],.size[1]' | tr '\\n' ' ' | awk '{printf \"%d,%d %dx%d\",$1,$2,$3,$4}')\" ~/Images/Screenshots/$(date +'%Y-%m-%d_%H-%M-%S').png"
      ];

      # Locked bindings (work even when screen is off/locked)
      bindl = [
        "SUPER SHIFT, P, dpms, toggle"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPrev, exec, playerctl previous"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86Calculator, exec, dms ipc call spotlight openQuery ="
      ];

      bindle = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86MonBrightnessUp, exec, brightnessctl set 5%+"
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
      ];

      # SUPER key alone triggers DMS spotlight (on release)
      bindr = [
        "SUPER, SUPER_L, exec, dms ipc call spotlight toggle"
      ];

      # Mouse bindings
      bindm = [
        "SUPER, mouse:272, movewindow"
        "SUPER, mouse:273, resizewindow"
      ];
    };
  };

  services.cliphist = {
    enable = true;
    allowImages = true;
  };

  programs.dsearch = {
    enable = true;
    config = {
      exclude = {
        directories = [ "node_modules" ".git" ".cache" "target" "build" "venv" ];
      };
      include = {
        paths = [ "/home/philippe" ];
      };
      indexing = {
        hidden = false;
      };
      search = {
        fuzzy = true;
      };
    };
  };
}
