{
  services.openssh = {
    enable = true;
    # Empêche NixOS de générer ses propres clés, car nous les fournissons manuellement.
    startWhenNeeded = false;
    hostKeys = [];
    openFirewall = true;
  };
}
