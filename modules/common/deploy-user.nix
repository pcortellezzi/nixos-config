{ config, pkgs, lib, ... }:

let
  # Create a self-contained script with all dependencies in its PATH.
  setupScript = pkgs.writeShellApplication {
    name = "setup-deploy-user";
    runtimeInputs = with pkgs; [ glibc coreutils shadow ]; # All packages whose binaries we need
    text = ''
      set -e
      # No need to set PATH or use absolute paths, runtimeInputs handles it.
      user="deploy-user"
      group="deploy-user"
      home="/var/lib/deploy-user"
      key="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFsgRqe1gSxB6MsnTW3McyfCyFSLlMtBfF/o/xaQkBni deploy-user"

      if ! getent group "$group" >/dev/null; then
        groupadd -r "$group"
      fi

      if ! getent passwd "$user" >/dev/null; then
        useradd -r -g "$group" -d "$home" -m -s "${pkgs.bash}/bin/bash" "$user"
      fi

      mkdir -p "$home/.ssh"
      echo "$key" > "$home/.ssh/authorized_keys"

      chown -R "$user:$group" "$home/.ssh"
      chmod 700 "$home/.ssh"
      chmod 600 "$home/.ssh/authorized_keys"
    '';
  };
in
{
  system.activationScripts.setup-deploy-user = {
    deps = [ "users" ];
    text = ''
      # Execute the self-contained script.
      ${setupScript}/bin/setup-deploy-user
    '';
  };

  # Grant passwordless sudo for the specific nixos-rebuild command.
  security.sudo.extraRules = [
    {
      users = [ "deploy-user" ];
      commands = [
        {
          command = "/nix/store/*/bin/switch-to-configuration switch";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  nix.settings.trusted-users = [ "deploy-user" ];
}
