{ config, lib, pkgs, ... }:
let
  containerName = "homeassistant";
in
{
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
          "home-assistant-config:/config"
        ];
        environment = {
          TZ = "America/Cayenne";
        };
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
