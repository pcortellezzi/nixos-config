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

    environmentFiles = [ config.age.secrets.hermes_api_keys.path ];
    environment.API_SERVER_ENABLED = "true";
    settings = {
      terminal = {
        user = "hermes";
        backend = "local";
      };
    };

  networking.firewall.allowedTCPPorts = [ 8642 ];
}
