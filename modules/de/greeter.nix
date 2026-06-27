{ pkgs, lib, ... }:

let
  maliit-keyboard = "${pkgs.maliit-keyboard}/bin/maliit-keyboard";
  kwin = lib.concatStringsSep " " [
    "${lib.getBin pkgs.kdePackages.kwin}/bin/kwin_wayland"
    "--no-global-shortcuts"
    "--no-kactivities"
    "--no-lockscreen"
    "--locale1"
    "--inputmethod ${maliit-keyboard}"
  ];
in {
  services.xserver.enable = true;

  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = false;
  services.displayManager.sddm.extraPackages = [
    pkgs.kdePackages.plasma-workspace
    pkgs.maliit-keyboard
  ];
  services.displayManager.sddm.settings.Wayland.CompositorCommand = kwin;

  systemd.services.display-manager.environment = {
    KWIN_IM_SHOW_ALWAYS = "1";
    LANG = "fr_FR.UTF-8";
    __GLX_VENDOR_LIBRARY_NAME = "mesa";
  };
}
