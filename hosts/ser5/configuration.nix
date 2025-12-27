{ ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../../modules/system.nix
      ../../modules/roles/nas.nix
    ];

  networking.hostName = "ser5";

  users.users.philippe = {
    isNormalUser = true;
    description = "Philippe CORTELLEZZI";
    extraGroups = [ "networkmanager" "wheel" ];
  };

}
