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
    };
      extraOptions = [ "--network=host" ];

    environmentFiles = [ config.age.secrets.hermes_api_keys.path ];
    environment.API_SERVER_ENABLED = "true";
  };

  networking.firewall.allowedTCPPorts = [ 8642 ];

  # Dashboard service (port 9119)
  systemd.services.hermes-dashboard = {
    description = "Hermes Agent Dashboard";
    after = [ "hermes-agent.service" "network.target" ];
    wants = [ "hermes-agent.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";
      Restart = "on-failure";
      RestartSec = 5;
      ExecStart = "${pkgs.podman}/bin/podman exec hermes-agent hermes dashboard";
    };
  };

  networking.firewall.allowedTCPPorts = [ 8642 9119 ];
}
