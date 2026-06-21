{ pkgs, ... }:

{
  services.xserver.desktopManager.gnome.enable = true;
  services.gnome.gnome-remote-desktop.enable = true;
  systemd.services.gnome-remote-desktop.wantedBy = [ "graphical.target" ];

  nixpkgs.overlays = [(final: prev: {
    gvfs = prev.gvfs.override { gnomeSupport = true; };
  })];

  environment.systemPackages = with pkgs; [
    gnome-extension-manager
    wl-clipboard
    ghostty
  ];
  environment.gnome.excludePackages = [ pkgs.gnome-console ];

}
