{
  config,
  lib,
  pkgs,
  ...
}:

{
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    publish = {
      enable = true;
      addresses = true;
      hinfo = true;
      userServices = true;
      workstation = true;
    };
  };

  environment.etc."avahi/services/device-info.service".text = lib.mkIf config.services.avahi.enable ''
    <?xml version="1.0" standalone='no'?>
    <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
    <service-group>
      <name replace-wildcards="yes">%h Device Info</name>
      <service>
        <type>_device-info._tcp</type>
        <port>0</port>
        <txt-record>model=Unix</txt-record>
      </service>
    </service-group>
  '';
}
