{ pkgs, ... }:

{
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.sddm.extraPackages = [ pkgs.kdePackages.plasma-workspace ];
}
