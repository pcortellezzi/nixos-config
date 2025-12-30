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
  ];

  programs.anyrun = {
    enable = true;
    config = {
      plugins = [
        inputs.anyrun.packages.${pkgs.stdenv.hostPlatform.system}.applications
        inputs.anyrun.packages.${pkgs.stdenv.hostPlatform.system}.rink
        inputs.anyrun.packages.${pkgs.stdenv.hostPlatform.system}.shell
        inputs.anyrun.packages.${pkgs.stdenv.hostPlatform.system}.symbols
        inputs.anyrun.packages.${pkgs.stdenv.hostPlatform.system}.stdin
        inputs.anyrun.packages.${pkgs.stdenv.hostPlatform.system}.websearch
      ];
      width = { fraction = 0.3; };
      y = { absolute = 15; };
      hideIcons = false;
      ignoreExclusiveZones = false;
      layer = "overlay";
      hidePluginInfo = true;
      closeOnClick = true;
      showResultsImmediately = false;
      maxEntries = null;
    };
    extraCss = ''
      @import url("file:///home/philippe/.cache/anyrun-theme.css");

      * {
        all: unset;
        font-family: "JetBrainsMono Nerd Font", sans-serif;
        font-size: 15px;
      }

      window {
        background: transparent;
      }

      .main {
        background-color: var(--m3-surface, rgba(16, 20, 24, 0.98));
        border: 1px solid var(--m3-outline, rgba(140, 145, 153, 0.3));
        border-radius: 24px;
        padding: 12px;
        box-shadow: 0 8px 32px rgba(0, 0, 0, 0.5);
      }

      #entry {
        background-color: var(--m3-surface-variant, rgba(66, 71, 78, 0.5));
        color: var(--m3-on-surface, #e0e2e8);
        border-radius: 16px;
        padding: 12px 16px;
        margin: 8px;
        caret-color: var(--m3-primary, #42a5f5);
      }

      .match {
        padding: 6px 12px;
        border-radius: 10px;
        margin: 1px 4px;
        color: var(--m3-on-surface, #e0e2e8);
        transition: background 0.1s ease;
      }

      .match:selected {
        background-color: var(--m3-primary-container, #0d47a1);
        color: var(--m3-on-surface, #e0e2e8);
      }

      .title {
        font-weight: bold;
      }

      .description {
        font-size: 0.85em;
        opacity: 0.8;
      }
    '';
  };

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
          JSON="$HOME/.cache/DankMaterialShell/dms-colors.json"
          CSS="$HOME/.cache/anyrun-theme.css"
          if [ -f "$JSON" ]; then
            PRIMARY=$(jq -r ".colors.dark.primary" "$JSON")
            SURFACE=$(jq -r ".colors.dark.surface" "$JSON")
            ON_SURFACE=$(jq -r ".colors.dark.on_surface" "$JSON")
            SURFACE_VARIANT=$(jq -r ".colors.dark.surface_variant" "$JSON")
            PRIMARY_CONTAINER=$(jq -r ".colors.dark.primary_container" "$JSON")
            OUTLINE=$(jq -r ".colors.dark.outline" "$JSON")
            printf ":root { --m3-primary: %s; --m3-surface: %s; --m3-on-surface: %s; --m3-surface-variant: %s; --m3-primary-container: %s; --m3-outline: %s; }" \
              "$PRIMARY" "$SURFACE" "$ON_SURFACE" "$SURFACE_VARIANT" "$PRIMARY_CONTAINER" "$OUTLINE" > "$CSS"
          fi
          inotifywait -e modify "$JSON" 2>/dev/null || sleep 5
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
          Mod+Space hotkey-overlay-title="Run an Application: anyrun" { spawn "anyrun"; }
          Mod+D hotkey-overlay-title="Clipboard History: cliphist" { spawn-sh "cliphist list | anyrun --plugins ${inputs.anyrun.packages.${pkgs.stdenv.hostPlatform.system}.stdin}/lib/libstdin.so | cliphist decode | wl-copy"; }
          Mod+B hotkey-overlay-title="Bitwarden" { spawn-sh "rbw list --fields name,user,folder | anyrun --plugins ${inputs.anyrun.packages.${pkgs.stdenv.hostPlatform.system}.stdin}/lib/libstdin.so | pkgs.gawk/bin/awk -F '\t' '{print $1}' | xargs -r rbw get --clipboard"; }

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
    '';

    "niri/outputs.kdl".text = ''
      output "LG Electronics LG HDR WQHD 204NTHMB9585" {
        mode "3440x1440@100.0"
        position x=0 y=0
        scale 1.0
      }
      output "LG Electronics LG HDR WQHD 204NTABB9600" {
        mode "3440x1440@100.0"
        position x=0 y=1440
        scale 1.0
      }
      output "Iiyama North America PL2730Q 1219930721568" {
        mode "2560x1440@60.0"
        position x=3440 y=0
        scale 1.0
        transform "270"
      }
      output "eDP-1" {
        mode "2880x1620@120.0"
        position x=4880 y=2100
        scale 1.75
      }
    '';
  };

  services.cliphist = {
    enable = true;
    allowImages = true;
  };

  systemd.user.services.anyrun = {
    Unit = {
      Description = "Anyrun Daemon";
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${config.programs.anyrun.package}/bin/anyrun daemon";
      Restart = "always";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
