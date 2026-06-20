{ config, lib, pkgs, ... }:

let
  cfg = config.my.krdp;
in
{
  options.my.krdp = {
    enable = lib.mkEnableOption "KRDP Remote Desktop server";
    username = lib.mkOption {
      type = lib.types.str;
      default = "philippe";
      description = "Username for RDP login";
    };
    password = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Password for RDP login (set via GUI or this option)";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.kdePackages.krdp ];

    networking.firewall.allowedTCPPorts = [ 3389 ];

    systemd.user.services.krdpserver = {
      description = "KRDP Server (KDE Remote Desktop)";
      after = [ "plasma-xdg-desktop-portal-kde.service" "plasma-core.target" ];
      wantedBy = [ "plasma-workspace.target" ];
      serviceConfig = {
        Type = "exec";
        ExecStart = "${pkgs.kdePackages.krdp}/bin/krdpserver"
          + " --username ${cfg.username}"
          + lib.optionalString (cfg.password != "") " --password ${cfg.password}";
        Restart = "on-abnormal";
      };
    };
  };
}
