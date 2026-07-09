{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    inputs.hermes-workspace.nixosModules.default
  ];

  services.hermes-workspace = {
    enable = true;
    package = pkgs.hermes-workspace;
    host = "0.0.0.0";
    port = 3000;
    hermesApiUrl = "http://127.0.0.1:8642";
    hermesDashboardUrl = "http://127.0.0.1:9119";
    passwordFile = config.age.secrets.hermes_api_keys.path;
    environmentFile = config.age.secrets.hermes_api_keys.path;
    cookieSecure = false;
  };

  systemd.services.hermes-workspace.serviceConfig.Restart = lib.mkForce "always";

  networking.firewall.allowedTCPPorts = [ 3000 ];
}
