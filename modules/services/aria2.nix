{ config, lib, pkgs, ... }:

with lib;

{
  options.aria2.downloadDir = mkOption {
    type = types.str;
    default = "/var/lib/aria2/downloads";
    description = "Directory where aria2 should store downloaded files.";
  };

  config = {
    age.secrets.aria2_rpc_token = {
      file = ../../secrets/aria2_rpc_token.age;
      owner = "root";
      group = "root";
      mode = "0400";
    };

    services.aria2 = {
      enable = true;
      rpcSecretFile = config.age.secrets.aria2_rpc_token.path;
      settings = {
        dir = config.aria2.downloadDir;
        rpc-listen-all = true;
      };
    };

    # Ouvre le port RPC d'Aria2 dans le pare-feu.
    networking.firewall.allowedTCPPorts = [ 6800 ];
  };
}
