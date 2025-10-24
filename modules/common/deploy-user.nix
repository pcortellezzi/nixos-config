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
  options.my.deploy-user.triggerUpdateScript = lib.mkOption {
    type = lib.types.package;
    description = "The script to trigger NixOS updates.";
    readOnly = true; # This option is set internally
  };

  config = {
    system.activationScripts.setup-deploy-user = {
      deps = [ "users" ];
      text = ''
        # Execute the self-contained script.
        ${setupScript}/bin/setup-deploy-user
      '';
    };

    # Create a wrapper script for triggering NixOS updates.
    # This script will be run by sudo and will launch the actual update via systemd-run.
    my.deploy-user.triggerUpdateScript = pkgs.writeShellScriptBin "trigger-nixos-update" ''
      #!${pkgs.runtimeShell}
      set -e
              echo "Attempting to acquire update lock and launch NixOS configuration switch..."
              if ! ${pkgs.util-linux}/bin/flock --nonblock /run/nixos-rebuild.lock -c "${pkgs.nixos-rebuild}/bin/nixos-rebuild switch -v --flake github:pcortellezzi/nixos-config#${config.networking.hostName} --refresh" ; then
                echo "Update lock already held. Skipping update." >&2
                exit 0 # Exit with 0 to indicate success (no action needed)
              fi    '';

        # Grant passwordless sudo for the specific wrapper script and systemctl/journalctl commands.

        security.sudo.extraRules = [

          {

            users = [ "deploy-user" ];

            commands = [

              {

                command = "/nix/store/*-system-path/bin/systemctl start --wait nixos-update-runner.service";

                options = [ "NOPASSWD" ];

              }

              {

                command = "/nix/store/*-system-path/bin/journalctl -u nixos-update-runner.service -n 50 --no-pager";

                options = [ "NOPASSWD" ];

              }

            ];

          }

        ];
    nix.settings.trusted-users = [ "deploy-user" ];
  };
}
