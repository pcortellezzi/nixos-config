{ config, lib, ... }:

{
  config = {
    services.home-assistant = {
      enable = true;
      openFirewall = true;
      extraComponents = [
        "esphome"
        "met"
        "radio_browser"
      ];
      config = {
        homeassistant = {
          name = "Home";
          unit_system = "metric";
          temperature_unit = "C";
        };
        http = {
          server_port = 8123;
        };
        default_config = {};
      };
    };

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
  };
}
