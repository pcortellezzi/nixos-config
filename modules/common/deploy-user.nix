{ config, pkgs, lib, ... }:

{
  options.my.deploy-user.triggerUpdateScript = lib.mkOption {
    type = lib.types.package;
    description = "The script to trigger NixOS updates.";
    readOnly = true;
  };

  config = {
    users.users.deploy-user = {
      isSystemUser = true;
      group = "deploy-user";
      home = "/var/lib/deploy-user";
      createHome = true;
      shell = pkgs.bash;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFsgRqe1gSxB6MsnTW3McyfCyFSLlMtBfF/o/xaQkBni deploy-user"
      ];
    };

    users.groups.deploy-user = { };

    my.deploy-user.triggerUpdateScript = pkgs.writeShellScriptBin "trigger-nixos-update" ''
      set -e
      echo "Attempting to acquire update lock and launch NixOS configuration switch..."
      if ! ${pkgs.util-linux}/bin/flock --nonblock /run/nixos-rebuild.lock -c "${pkgs.nixos-rebuild}/bin/nixos-rebuild switch -v --flake github:pcortellezzi/nixos-config#${config.networking.hostName} --refresh" ; then
        echo "Update lock already held. Skipping update." >&2
        exit 0
      fi
    '';

    security.sudo.extraRules = [
      {
        users = [ "deploy-user" ];
        commands = [
          {
            command = "/run/current-system/sw/bin/systemctl start --wait nixos-update-runner.service";
            options = [ "NOPASSWD" ];
          }
          {
            command = "/run/current-system/sw/bin/systemctl start --no-block nixos-update-runner.service";
            options = [ "NOPASSWD" ];
          }
          {
            command = "/run/current-system/sw/bin/journalctl -u nixos-update-runner.service -n 50 --no-pager";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];

    nix.settings.trusted-users = [ "deploy-user" ];
  };
}
