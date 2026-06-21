{ pkgs, ... }:

{
  services.xserver.desktopManager.gnome.enable = true;
  services.gnome.gnome-remote-desktop.enable = true;
  systemd.services.gnome-remote-desktop.wantedBy = [ "graphical.target" ];

  services.dbus.packages = [ pkgs.gpaste ];
  environment.systemPackages = [ pkgs.gpaste ];

  systemd.user.services.gpaste-daemon = {
    description = "GPaste daemon";
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "dbus";
      BusName = "org.gnome.GPaste";
      ExecStart = "${pkgs.gpaste}/libexec/gpaste/gpaste-daemon";
    };
  };
}
