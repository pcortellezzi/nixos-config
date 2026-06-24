{ pkgs, ... }:

{
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.sddm.extraPackages = [ pkgs.qt6.qtvirtualkeyboard ];
  services.displayManager.sddm.settings.General.InputMethod = "qtvirtualkeyboard";
}
