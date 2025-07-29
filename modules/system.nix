{ pkgs, lib, config, ... }:

{
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Enable networking
  networking.networkmanager.enable = true;

  networking.firewall.trustedInterfaces = [ "lo" ];

  imports = [
    ./services/openssh.nix
    ./services/avahi.nix
    ./services/resolved.nix
    ./common/locale.nix
    ./common/wifi-networks.nix
    ./common/deploy-user.nix
  ];

  

  # Enable Nix experimental features for flakes and nix-command
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Configure Cachix for pcortellezzi cache
  nix.settings.substituters = [ "https://pcortellezzi.cachix.org" ];

  # Ajoute la clé publique de la machine de construction (vvb) à la liste de confiance.
  # NixOS fusionnera automatiquement cette valeur avec les clés par défaut.
  nix.settings.trusted-public-keys = [
    "pcortellezzi.cachix.org-1:IL7g88BOsIf1AeFl37PclJtA/lLY6Auf3xtRh30M0fI="
  ];

  

  

  # Configure a global known_hosts file for all users.
  programs.ssh.knownHosts = lib.mapAttrs' (hostName: hostKey: {
    name = hostName;
    value = { publicKey = hostKey; hostNames = [ hostName ]; };
  }) (import ../lib/ssh-host-keys.nix);

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
}
