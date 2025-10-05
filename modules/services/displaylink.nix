{ pkgs, ... }:

{
  # 1. Installe notre paquet displaylink
  environment.systemPackages = [ pkgs.displaylink ];

  # 2. Active les règles udev de notre paquet (corrige la détection)
  services.udev.packages = [ pkgs.displaylink ];

  # 3. Définit et active le service systemd nous-mêmes (corrige le démarrage)
  systemd.services.displaylink = {
    description = "DisplayLink Manager Service";
    after = [ "systemd-udevd.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.displaylink}/bin/DisplayLinkManager";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
}
