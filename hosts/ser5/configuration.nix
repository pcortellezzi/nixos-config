{ ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../../modules/system.nix
      ../../modules/roles/nas.nix
      ../../modules/roles/domotique.nix
      ../../modules/roles/trading-bot.nix
    ];

  networking.hostName = "ser5";

  users.users.philippe = {
    isNormalUser = true;
    description = "Philippe CORTELLEZZI";
    extraGroups = [ "networkmanager" "wheel" ];
  };

}
