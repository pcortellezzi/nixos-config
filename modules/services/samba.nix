{ config, lib, pkgs, ... }:

with lib;

{
  options.samba.serverName = mkOption {
    type = types.str;
    default = config.networking.hostName;
    description = "The NetBIOS name and server string for Samba.";
  };

  options.samba.shares = mkOption {
    type = types.attrsOf (types.attrsOf types.anything);
    default = {};
    description = "Samba shares to configure.";
  };

  config = {
    services.samba = {
      enable = true;
      openFirewall = true;
      settings = {
        global = {
          "workgroup" = "HOME";
          "server string" = config.samba.serverName;
          "netbios name" = config.samba.serverName;
          "security" = "user";
          "guest account" = "nobody";
          "map to guest" = "bad user";
        };
      } // config.samba.shares;
    };

    services.samba-wsdd.enable = true;

    environment.etc."avahi/services/samba.service".text = lib.mkIf config.services.avahi.enable ''
      <?xml version="1.0" standalone='no'?>
      <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
      <service-group>
        <name replace-wildcards="yes">%h</name>
        <service>
          <type>_smb._tcp</type>
          <port>445</port>
        </service>
        <service>
          <type>_device-info._tcp</type>
          <port>0</port>
          <txt-record>model=Samba</txt-record>
        </service>
      </service-group>
    '';
  };
}
