{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    inputs.hermes-agent.nixosModules.default
  ];

  age.secrets.hermes_api_keys = {
    file = ../../secrets/hermes_api_keys.age;
    owner = "hermes";
    group = "root";
    mode = "0400";
  };

  services.hermes-agent = {
    enable = true;
    stateDir = "/srv/samba/plex/hermes-agent";

    container = {
      enable = true;
      backend = "podman";
      extraOptions = [ "--network=host" ];
    };

    environmentFiles = [ config.age.secrets.hermes_api_keys.path ];
    environment.API_SERVER_ENABLED = "true";
  };



  # Dashboard service (port 9119)
  systemd.services.hermes-dashboard = {
    description = "Hermes Agent Dashboard";
    after = [ "hermes-agent.service" "network.target" ];
    wants = [ "hermes-agent.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = 10;
      ExecStart = "${pkgs.podman}/bin/podman exec hermes-agent hermes dashboard";
      # Wait for container to be ready before starting
      ExecStartPre = "${pkgs.bash}/bin/bash -c 'for i in \$(seq 30); do ${pkgs.podman}/bin/podman exec hermes-agent true 2>/dev/null && exit 0; sleep 2; done; exit 1'";
    };
  };

  networking.firewall.allowedTCPPorts = [ 8642 9119 ];
}
