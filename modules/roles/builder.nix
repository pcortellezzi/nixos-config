{ ... }:

{
  # Déploie la clé de signature de cette machine via agenix.
  age.secrets.nix_signing_key = {
    file = ../../secrets/nix_signing_key.age;
    path = "/etc/nix/signing-key.sec";
    owner = "root";
    group = "root";
    mode = "0400"; # Clé privée, lecture seule pour root.
    symlink = false;
  };

  # S'''assure que le nix-daemon démarre APRÈS que sa clé de signature a été déchiffrée.
  systemd.services.nix-daemon.after = [ "agenix.service" ];

  # Dit à Nix d'''utiliser cette clé pour signer les paquets.
  nix.settings.secret-key-files = [ "/etc/nix/signing-key.sec" ];
}
