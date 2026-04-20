{ pkgs, ... }:

{
  environment.sessionVariables = {
    GDK_BACKEND = "wayland,x11";
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";
    NIXOS_OZONE_WL = "1";
    QT_FONT_DPI = "120";

    # Force AMD iGPU (card1) as primary renderer for Hyprland/Aquamarine
    # This is needed for DisplayLink/EVDI to work properly
    AQ_DRM_DEVICES = "/dev/dri/card1";
  };
}
