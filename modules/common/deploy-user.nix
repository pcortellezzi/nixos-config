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
      echo "Attempting to acquire update lock and launch NixOS configuration switch..."

      notify_user() {
        local icon="$1" title="$2" body="$3"
        for uid in $(${pkgs.systemd}/bin/loginctl list-users --no-legend | ${pkgs.gawk}/bin/awk '{print $1}'); do
          local user=$(${pkgs.systemd}/bin/loginctl list-users --no-legend | ${pkgs.gawk}/bin/awk -v u="$uid" '$1==u {print $2}')
          local runtime_dir="/run/user/$uid"
          if [ -d "$runtime_dir" ]; then
            ${pkgs.sudo}/bin/sudo -u "$user" \
              DBUS_SESSION_BUS_ADDRESS="unix:path=$runtime_dir/bus" \
              ${pkgs.libnotify}/bin/notify-send -i "$icon" "$title" "$body" 2>/dev/null || true
          fi
        done
      }

      rc=0
      ${pkgs.util-linux}/bin/flock --nonblock --conflict-exit-code 100 /run/nixos-rebuild.lock -c \
        "${pkgs.nixos-rebuild}/bin/nixos-rebuild switch -v --flake github:pcortellezzi/nixos-config#${config.networking.hostName} --refresh" \
        || rc=$?

      if [ "$rc" -eq 100 ]; then
        echo "Update lock already held. Skipping update." >&2
        exit 0
      elif [ "$rc" -ne 0 ]; then
        notify_user "dialog-error" "NixOS" "Configuration switch failed (exit $rc)."
        exit "$rc"
      fi

      notify_user "emblem-default" "NixOS" "Configuration applied successfully."
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
