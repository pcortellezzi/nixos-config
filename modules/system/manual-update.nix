{ config, lib, pkgs, ... }:

let
  cfg = config.my.manual-update;

  updateScript = pkgs.writeShellApplication {
    name = "nixos-update";
    runtimeInputs = with pkgs; [ git nix systemd ];
    text = ''
      REPO_DIR="${cfg.repoPath}"

      echo "==> Updating NixOS configuration..."
      cd "$REPO_DIR"

      echo "==> git pull..."
      git pull --ff-only

      echo "==> nix flake update..."
      nix flake update

      if git diff --quiet flake.lock; then
        echo "==> No flake input changes."
      else
        echo "==> Committing flake.lock update..."
        git add flake.lock
        git commit -m "flake: update inputs"
        echo "==> Pushing to remote..."
        git push
      fi

      echo "==> Rebuilding NixOS from remote flake..."
      sudo systemctl start --wait nixos-update-runner.service
      echo "==> Build logs:"
      sudo journalctl -u nixos-update-runner.service -n 100 --no-pager
      echo "==> Update complete!"
    '';
  };
in
{
  options.my.manual-update = {
    enable = lib.mkEnableOption "manual NixOS update script";

    repoPath = lib.mkOption {
      type = lib.types.str;
      default = "/home/philippe/Projects/nixos-config";
      description = "Path to the NixOS configuration repository.";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "philippe";
      description = "User allowed to trigger manual updates.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ updateScript ];

    security.sudo.extraRules = [
      {
        users = [ cfg.user ];
        commands = [
          {
            command = "/nix/store/*-system-path/bin/systemctl start --wait nixos-update-runner.service";
            options = [ "NOPASSWD" ];
          }
          {
            command = "/nix/store/*-system-path/bin/journalctl -u nixos-update-runner.service -n 100 --no-pager";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };
}
