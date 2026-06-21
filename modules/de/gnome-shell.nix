{ pkgs, ... }:

{
  services.xserver.desktopManager.gnome.enable = true;
  services.gnome.gnome-remote-desktop.enable = true;
  systemd.services.gnome-remote-desktop.wantedBy = [ "graphical.target" ];

  environment.systemPackages = with pkgs; [
    gnome-extension-manager
    wl-clipboard
    ghostty
    rclone
  ];
  environment.gnome.excludePackages = [ pkgs.gnome-console ];

}
