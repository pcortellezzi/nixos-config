{ config, lib, pkgs, ... }:

let
  cfg = config.my.auto-update;
  # The URL of your NixOS configuration repository
  flakeUrl = "github:pcortellezzi/nixos-config";
in
{
  options.my.auto-update = {
    enable = lib.mkEnableOption "NixOS auto-update on boot";
  };

  config = lib.mkIf cfg.enable (
    {
      # The actual worker service that performs the update
      systemd.services.nixos-update-runner = {
        description = "NixOS Update Runner (performs the actual switch)";
        # No WantedBy, it's triggered by nixos-auto-update.service or CI
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        serviceConfig = {
          Type = "oneshot";
          User = "root";
          ExecStart = "${config.my.deploy-user.triggerUpdateScript}/bin/trigger-nixos-update";
        };
      };

      # The boot-time trigger service
      systemd.services.nixos-auto-update = {
        description = "Automatically trigger NixOS update on boot";
        wantedBy = [ "multi-user.target" ];
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        serviceConfig = {
          Type = "oneshot";
          User = "root";
          ExecStart = "${pkgs.systemd}/bin/systemctl start --no-block nixos-update-runner.service";
        };
      };
    }
  );
}