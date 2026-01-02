{ pkgs, ... }:

{
  services.displayManager.dms-greeter = {
    enable = true;
    compositor.name = "niri";  # Or "hyprland" or "sway"

    # Sync your user's DankMaterialShell theme with the greeter. You'll probably want this
    configHome = "/home/philippe";

    # Custom config files for non-standard config locations
    configFiles = [
      "/home/philippe/.config/DankMaterialShell/settings.json"
    ];
  };
}
