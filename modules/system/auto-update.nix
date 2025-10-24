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
    let
      updateScript = pkgs.writeShellScriptBin "nixos-auto-update" ''
        #!${pkgs.runtimeShell}
        set -e
        echo "Attempting to update NixOS configuration from ${flakeUrl}..."
        ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake ${flakeUrl}#${config.networking.hostName}
        echo "NixOS configuration update process completed."
      '';
    in
    {
            systemd.services.nixos-auto-update = {
              description = "Automatically update NixOS configuration from GitHub on boot";
              wantedBy = [ "multi-user.target" ];
              after = [ "network-online.target" ];
              wants = [ "network-online.target" ];
                      serviceConfig = {
                        Type = "oneshot";
                        User = "root";
                        ExecStart = "${pkgs.util-linux}/bin/flock --nonblock /run/nixos-rebuild.lock -c '${updateScript}/bin/nixos-auto-update'";
                        SuccessExitStatus = 1;
                      };            };    }
  );
}