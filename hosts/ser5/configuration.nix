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

  # Autorise l'''utilisateur 'philippe' à effectuer des opérations Nix de confiance.
  # C'''est nécessaire pour que l'''option `--option require-sigs false` fonctionne.
  nix.settings.trusted-users = [ "root" "philippe" ];

  

  
}
