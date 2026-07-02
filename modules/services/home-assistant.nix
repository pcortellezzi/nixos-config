{ config, lib, pkgs, ... }:
let
  containerName = "homeassistant";
in
{
  systemd.tmpfiles.rules = [
    "d /srv/homeassistant/config 0755 root root -"
    "d /srv/homeassistant/config/custom_components 0755 root root -"
  ];

  systemd.services.seed-hacs = {
    description = "Seed HACS into Home Assistant config on first boot";
    before = [ "podman-${containerName}.service" ];
    wantedBy = [ "podman-${containerName}.service" ];
    script = ''
      if [ ! -f /srv/homeassistant/config/custom_components/hacs/manifest.json ]; then
        mkdir -p /srv/homeassistant/config/custom_components
        ${pkgs.wget}/bin/wget -q -O /tmp/hacs.zip \
          https://github.com/hacs/integration/releases/latest/download/hacs.zip
        ${pkgs.unzip}/bin/unzip -q -o /tmp/hacs.zip \
          -d /srv/homeassistant/config/custom_components/hacs
        rm /tmp/hacs.zip
      fi
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };

  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };
    oci-containers = {
      backend = "podman";
      containers.${containerName} = {
        image = "ghcr.io/home-assistant/home-assistant:stable";
        autoStart = true;
        volumes = [
          "/srv/homeassistant/config:/config"
        ];
        environment.TZ = "America/Cayenne";
        extraOptions = [
          "--network=host"
          "--label=io.containers.autoupdate=registry"
        ];
      };
    };
  };

  systemd.services.podman-auto-update-homeassistant = {
    description = "Podman auto-update Home Assistant container";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.podman}/bin/podman auto-update --format=json";
    };
  };

  systemd.timers.podman-auto-update-homeassistant = {
    description = "Weekly Home Assistant container image update";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
    };
  };

  networking.firewall.allowedTCPPorts = [ 8123 ];

  environment.etc."avahi/services/home-assistant.service".text = lib.mkIf config.services.avahi.enable ''
    <?xml version="1.0" standalone='no'?>
    <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
    <service-group>
      <name replace-wildcards="yes">%h Home Assistant</name>
      <service>
        <type>_home-assistant._tcp</type>
        <port>8123</port>
      </service>
    </service-group>
  '';
}
