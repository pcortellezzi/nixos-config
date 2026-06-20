{ config, lib, pkgs, ... }:

let
  cfg = config.my.sunshine;
in
{
  options.my.sunshine = {
    enable = lib.mkEnableOption "Sunshine game stream host (Moonlight server)";
    capSysAdmin = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Give CAP_SYS_ADMIN for DRM/KMS display capture (required for Wayland)";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.sunshine ];

    networking.firewall = {
      allowedTCPPorts = [ 47989 47984 47990 ];
      allowedUDPPorts = [ 47984 47999 48000 48010 ];
    };

    security.wrappers.sunshine = lib.mkIf cfg.capSysAdmin {
      owner = "root";
      group = "root";
      capabilities = "cap_sys_admin+p";
      source = "${pkgs.sunshine}/bin/sunshine";
    };

    systemd.user.services.sunshine = {
      description = "Sunshine Game Stream Host";
      partOf = [ "graphical-session.target" ];
      wantedBy = [ "graphical-session.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = if cfg.capSysAdmin
          then "${config.security.wrapperDir}/sunshine"
          else "${pkgs.sunshine}/bin/sunshine";
        Restart = "on-failure";
        RestartSec = "5";
      };
    };

    services.udev.packages = [ pkgs.sunshine ];
  };
}
