{ config, pkgs, lib, ... }:

with lib;

{
  config = {
    services.plex = {
      enable = true;
      openFirewall = true;
    };

    environment.etc."avahi/services/plex.service".text = lib.mkIf config.services.avahi.enable ''
      <?xml version="1.0" standalone='no'?>
      <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
      <service-group>
        <name replace-wildcards="yes">%h Plex Media Server</name>
        <service>
          <type>_plexmediasvr._tcp</type>
          <port>32400</port>
        </service>
        <service>
          <type>_upnp._tcp</type>
          <port>8200</port>
        </service>
        <service>
          <type>_urn:schemas-upnp-org:device:MediaServer:1._tcp</type>
          <port>8200</port>
        </service>
      </service-group>
    '';
  };
}
