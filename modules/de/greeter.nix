{ pkgs, ... }:

{
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.sddm.extraPackages = [ pkgs.kdePackages.plasma-workspace ];

  systemd.services.display-manager.environment.KWIN_IM_SHOW_ALWAYS = "1";
}
