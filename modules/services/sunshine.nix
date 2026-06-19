{ config, lib, pkgs, ... }:

let
  cfg = config.my.sunshine;
in
{
  options.my.sunshine = {
    enable = lib.mkEnableOption "Sunshine game stream host (Moonlight server)";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.sunshine ];

    networking.firewall = {
      allowedTCPPorts = [ 47989 47984 47990 ];
      allowedUDPPorts = [ 47984 47999 48000 48010 ];
    };

    systemd.user.services.sunshine = {
      description = "Sunshine Game Stream Host";
      partOf = [ "graphical-session.target" ];
      wantedBy = [ "graphical-session.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.sunshine}/bin/sunshine";
        Restart = "on-failure";
        RestartSec = "5";
      };
    };

    services.udev.packages = [ pkgs.sunshine ];
  };
}
