{ config, pkgs, inputs, ... }:

{
  home.packages = with pkgs; [
    alacritty
    brightnessctl
    nautilus
    cliphist
    wl-clipboard
    rbw
    jq
    inotify-tools
    pkgs.hamr
  ];

  xdg.configFile = {
    "niri/config.kdl".text = ''
      include "./dms/colors.kdl"
      include "./dms/layout.kdl"
      include "./dms/alttab.kdl"
      include "./dms/binds.kdl"
      include "./dms/wpblur.kdl"

      include "./input.kdl"
      include "./window-rules.kdl"
      include "./binds.kdl"
      include "./settings.kdl"
      include "./outputs.kdl"
    '';

    "niri/input.kdl".text = ''
      input {
          keyboard {
              numlock
          }

          touchpad {
              tap
              natural-scroll
          }
      }
    '';

    "niri/layout.kdl".text = ''
      layout {
          preset-column-widths {
              proportion 0.33333
              proportion 0.5
              proportion 0.66667
          }

          default-column-width { proportion 0.5; }
      }
    '';

    "niri/window-rules.kdl".text = ''
      window-rule {
          match app-id=r#"^org\.wezfurlong\.wezterm$"#
          default-column-width {}
      }

      window-rule {
          match app-id=r#"firefox$"# title="^Picture-in-Picture$"
          open-floating true
      }
    '';

    "niri/settings.kdl".text = ''
      spawn-at-startup "bash" "-c" r#"
        while true; do
          JSON_DMS=\"$HOME/.cache/DankMaterialShell/dms-colors.json\";
          HAMR_CONF=\"$HOME/.config/hamr\";
          mkdir -p \"$HAMR_CONF\";
          if [ -f \"$JSON_DMS\" ]; then
            # Hamr expects a specific colors.json format
            # We map DMS colors to Hamr expected names if needed
            jq \".colors.dark\" \"$JSON_DMS\" > \"$HAMR_CONF/colors.json\";
          fi
          inotifywait -e modify \"$JSON_DMS\" 2>/dev/null || sleep 5
        done
      "#

      hotkey-overlay {
      }

      screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"
    '';

    "niri/binds.kdl".text = ''
      binds {
          Mod+Shift+M { show-hotkey-overlay; }

          Mod+T hotkey-overlay-title="Open a Terminal: alacritty" { spawn "alacritty"; }
          Mod+Space hotkey-overlay-title="Toggle Launcher: hamr" { spawn "hamr" "ipc" "call" "hamr" "toggle"; }

          Mod+O repeat=false { toggle-overview; }

          Mod+Q repeat=false { close-window; }

          Mod+Left  { focus-column-left; }
          Mod+Down  { focus-window-down; }
          Mod+Up    { focus-window-up; }
          Mod+Right { focus-column-right; }
          Mod+H     { focus-column-left; }
          Mod+J     { focus-window-down; }
          Mod+K     { focus-window-up; }
          Mod+L     { focus-column-right; }

          Mod+Ctrl+Left  { move-column-left; }
          Mod+Ctrl+Down  { move-window-down; }
          Mod+Ctrl+Up    { move-window-up; }
          Mod+Ctrl+Right { move-column-right; }
          Mod+Ctrl+H     { move-column-left; }
          Mod+Ctrl+J     { move-window-down; }
          Mod+Ctrl+K     { move-window-up; }
          Mod+Ctrl+L     { move-column-right; }

          Mod+Home { focus-column-first; }
          Mod+End  { focus-column-last; }
          Mod+Ctrl+Home { move-column-to-first; }
          Mod+Ctrl+End  { move-column-to-last; }

          Mod+Shift+Left  { focus-monitor-left; }
          Mod+Shift+Down  { focus-monitor-down; }
          Mod+Shift+Up    { focus-monitor-up; }
          Mod+Shift+Right { focus-monitor-right; }
          Mod+Shift+H     { focus-monitor-left; }
          Mod+Shift+J     { focus-monitor-down; }
          Mod+Shift+K     { focus-monitor-up; }
          Mod+Shift+L     { focus-monitor-right; }

          Mod+Shift+Ctrl+Left  { move-column-to-monitor-left; }
          Mod+Shift+Ctrl+Down  { move-column-to-monitor-down; }
          Mod+Shift+Ctrl+Up    { move-column-to-monitor-up; }
          Mod+Shift+Ctrl+Right { move-column-to-monitor-right; }
          Mod+Shift+Ctrl+H     { move-column-to-monitor-left; }
          Mod+Shift+Ctrl+J     { move-column-to-monitor-down; }
          Mod+Shift+Ctrl+K     { move-column-to-monitor-up; }
          Mod+Shift+Ctrl+L     { move-column-to-monitor-right; }

          Mod+Page_Down      { focus-workspace-down; }
          Mod+Page_Up        { focus-workspace-up; }
          Mod+U              { focus-workspace-down; }
          Mod+I              { focus-workspace-up; }
          Mod+Ctrl+Page_Down { move-column-to-workspace-down; }
          Mod+Ctrl+Page_Up   { move-column-to-workspace-up; }
          Mod+Ctrl+U         { move-column-to-workspace-down; }
          Mod+Ctrl+I         { move-column-to-workspace-up; }

          Mod+Shift+Page_Down { move-workspace-down; }
          Mod+Shift+Page_Up   { move-workspace-up; }
          Mod+Shift+U         { move-workspace-down; }
          Mod+Shift+I         { move-workspace-up; }

          Mod+WheelScrollDown      cooldown-ms=150 { focus-workspace-down; }
          Mod+WheelScrollUp        cooldown-ms=150 { focus-workspace-up; }
          Mod+Ctrl+WheelScrollDown cooldown-ms=150 { move-column-to-workspace-down; }
          Mod+Ctrl+WheelScrollUp   cooldown-ms=150 { move-column-to-workspace-up; }

          Mod+WheelScrollRight      { focus-column-right; }
          Mod+WheelScrollLeft       { focus-column-left; }
          Mod+Ctrl+WheelScrollRight { move-column-right; }
          Mod+Ctrl+WheelScrollLeft  { move-column-left; }

          Mod+Shift+WheelScrollDown      { focus-column-right; }
          Mod+Shift+WheelScrollUp        { focus-column-left; }
          Mod+Ctrl+Shift+WheelScrollDown { move-column-right; }
          Mod+Ctrl+Shift+WheelScrollUp   { move-column-left; }

          Mod+Ampersand { focus-workspace 1; }
          Mod+Eacute    { focus-workspace 2; }
          Mod+Quotedbl  { focus-workspace 3; }
          Mod+Apostrophe { focus-workspace 4; }
          Mod+ParenLeft { focus-workspace 5; }
          Mod+Minus     { focus-workspace 6; }
          Mod+Egrave    { focus-workspace 7; }
          Mod+Underscore { focus-workspace 8; }
          Mod+Ccedilla  { focus-workspace 9; }
          Mod+Ctrl+Ampersand { move-column-to-workspace 1; }
          Mod+Ctrl+Eacute    { move-column-to-workspace 2; }
          Mod+Ctrl+Quotedbl  { move-column-to-workspace 3; }
          Mod+Ctrl+Apostrophe { move-column-to-workspace 4; }
          Mod+Ctrl+ParenLeft { move-column-to-workspace 5; }
          Mod+Ctrl+Minus     { move-column-to-workspace 6; }
          Mod+Ctrl+Egrave    { move-column-to-workspace 7; }
          Mod+Ctrl+Underscore { move-column-to-workspace 8; }
          Mod+Ctrl+Ccedilla  { move-column-to-workspace 9; }

          Mod+Dead_Circumflex { consume-or-expel-window-left; }
          Mod+Dollar          { consume-or-expel-window-right; }

          Mod+Comma  { consume-window-into-column; }
          Mod+Semicolon { expel-window-from-column; }

          Mod+R { switch-preset-column-width; }
          Mod+Shift+R { switch-preset-window-height; }
          Mod+Ctrl+R { reset-window-height; }
          Mod+F { maximize-column; }
          Mod+Shift+F { fullscreen-window; }

          Mod+Ctrl+F { expand-column-to-available-width; }

          Mod+C { center-column; }

          Mod+Ctrl+C { center-visible-columns; }

          Mod+ParenRight { set-column-width "-10%"; }
          Mod+Equal { set-column-width "+10%"; }

          Mod+Shift+ParenRight { set-window-height "-10%"; }
          Mod+Shift+Equal { set-window-height "+10%"; }

          Mod+V       { toggle-window-floating; }
          Mod+Shift+V { switch-focus-between-floating-and-tiling; }

          Mod+W { toggle-column-tabbed-display; }

          Mod+Escape allow-inhibiting=false { toggle-keyboard-shortcuts-inhibit; }

          Ctrl+Alt+Delete { quit; }

          Mod+Shift+P { power-off-monitors; }
      }
      output "eDP-1" {
        mode "2880x1620@120.0"
        position x=4880 y=2100
        scale 1.75
      }
    '';
  };

  xdg.configFile."hamr/config.json".text = builtins.toJSON {
    plugins = [ "applications" "calculator" "niri" "clipboard" "bitwarden" ];
    calculator = {
      prefix = "";
    };
  };

  services.cliphist = {
    enable = true;
    allowImages = true;
  };

  systemd.user.services.hamr = {
    Unit = {
      Description = "Hamr Launcher Daemon";
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.hamr}/bin/hamr";
      Restart = "always";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
