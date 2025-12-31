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

  
}
