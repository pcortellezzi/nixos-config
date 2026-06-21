{ ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./nvidia.nix
      ../../modules/system.nix
      ../../modules/roles/desktop.nix
    ];

  networking.hostName = "vvb";

  hardware.i2c.enable = true;

  users.users.philippe = {
    isNormalUser = true;
    description = "Philippe CORTELLEZZI";
    extraGroups = [ "networkmanager" "wheel" "i2c" ];
  };

  # GNOME avec Remote Desktop (écran virtuel étendu + curseur)
  services.xserver.desktopManager.gnome.enable = true;
  services.gnome.gnome-remote-desktop.enable = true;
  systemd.services.gnome-remote-desktop.wantedBy = [ "graphical.target" ];
  networking.firewall.allowedTCPPorts = [ 3389 ];


  
}
