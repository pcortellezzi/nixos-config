{
  pkgs, ...
}:

{
  # Enable bluetooth
  hardware.bluetooth.enable = true;
  environment.systemPackages = with pkgs; [
    bluez
    bluez-tools
    kdePackages.bluedevil
  ];
}
