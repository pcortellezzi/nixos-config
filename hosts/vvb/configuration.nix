{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./nvidia.nix
      ../../modules/system.nix
      ../../modules/roles/desktop.nix
      ../../modules/services/virtual-display.nix
      ../../modules/services/kmsvnc.nix
    ];

  networking.hostName = "vvb";

  hardware.i2c.enable = true;

  users.users.philippe = {
    isNormalUser = true;
    description = "Philippe CORTELLEZZI";
    extraGroups = [ "networkmanager" "wheel" "i2c" ];
  };

  environment.sessionVariables = {
    KWIN_FORCE_SW_CURSOR = "1";
  };
}
