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

  config = lib.mkIf cfg.enable {
    systemd.services.nixos-auto-update = {
      description = "Automatically update NixOS configuration from GitHub on boot";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        # Ensure that the system has access to the internet to fetch the flake
        ExecStart = "${pkgs.bash}/bin/bash -c ${pkgs.lib.escapeShellArg (pkgs.lib.concatStringsSep "\n" [
          "echo \"Attempting to update NixOS configuration from ${flakeUrl}...\""
          "${pkgs.nix}/bin/nix flake update --flake ${flakeUrl} || { echo \"Failed to update flake inputs.\"; exit 1; }"
          "${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake ${flakeUrl}#${config.networking.hostName} || { echo \"Failed to switch NixOS configuration.\"; exit 1; }"
          "echo \"NixOS configuration update process completed.\""
        ])}";
      };
    };
  };
}