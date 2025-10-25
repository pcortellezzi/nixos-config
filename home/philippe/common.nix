{ config, pkgs, lib, ... }:

{
  imports = [
    ../../modules/home-manager/direnv.nix
  ];

  home = {
    username = "philippe";
    homeDirectory = "/home/philippe";
    stateVersion = "25.05";
  };

  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    userKnownHostsFile = "${config.home.homeDirectory}/.ssh/known_hosts ${config.home.homeDirectory}/.ssh/known_hosts_declarative";

    matchBlocks = {
      "github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = "${config.home.homeDirectory}/.ssh/id_ed25519";
        identitiesOnly = true;
      };
    };
  };

  programs.bash = {
    enable = true;
  };


  home.file = {
    # Déploie le fichier de clé publique de manière déclarative.
    ".ssh/id_ed25519.pub" = {
      source = ./secrets/id_ed25519.pub;
    };

    # Gère directement le contenu du fichier authorized_keys.
    ".ssh/authorized_keys" = {
      text = builtins.readFile ./secrets/id_ed25519.pub;
    };
  };
}
