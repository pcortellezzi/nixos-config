{ pkgs, lib, config, stateVersion, ... }:

{
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use lqx kernel.
  boot.kernelPackages = pkgs.linuxPackages_lqx;
  boot.kernelParams = [
    "quiet"
    "splash"
  ];

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
  systemd.services.nix-daemon.serviceConfig.LimitNOFILE = lib.mkForce (1048576 * 2);

  # Configure Cachix for pcortellezzi cache
  nix.settings.substituters = [
    "https://cache.nixos.org/"
    "https://pcortellezzi.cachix.org"
    "https://cosmic.cachix.org/"
    "https://cache.numtide.com"
  ];

  # Ajoute la clé publique de la machine de construction (vvb) à la liste de confiance.
  # NixOS fusionnera automatiquement cette valeur avec les clés par défaut.
  nix.settings.trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "pcortellezzi.cachix.org-1:IL7g88BOsIf1AeFl37PclJtA/lLY6Auf3xtRh30M0fI="
    "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE="
    "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
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
  system.stateVersion = stateVersion; # Did you read the comment?

  security.pam.loginLimits = [
    {
      domain = "*";
      type = "soft";
      item = "nofile";
      value = "8192";
    }
    {
      domain = "*";
      type = "hard";
      item = "nofile";
      value = "65536";
    }
  ];

  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
}
