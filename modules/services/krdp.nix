{ config, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.kdePackages.krdp ];

  networking.firewall.allowedTCPPorts = [ 3389 ];

  systemd.user.services.krdpserver = {
    description = "KRDP Server (KDE Remote Desktop)";
    after = [ "plasma-xdg-desktop-portal-kde.service" "plasma-core.target" ];
    wantedBy = [ "plasma-workspace.target" ];
    serviceConfig = {
      Type = "exec";
      ExecStart = "${pkgs.kdePackages.krdp}/bin/krdpserver";
      Restart = "on-abnormal";
    };
  };
}
