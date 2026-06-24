{ pkgs, ... }:

{
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.sddm.virtualKeyboard = {
    enable = true;
    layout = "fr";
  };
}
