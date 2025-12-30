{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.solaar ];

  # Solaar needs udev rules to access Logitech devices
  services.udev.packages = [ pkgs.solaar ];
}