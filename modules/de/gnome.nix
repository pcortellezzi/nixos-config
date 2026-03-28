{ pkgs, ... }:

{
  services.desktopManager.gnome.enable = true;

  # Exclude default GNOME apps that are rarely used
  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    epiphany
  ];
}
