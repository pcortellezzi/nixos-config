{ lib, config, ... }:

{
  networking.nameservers = [ "1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one" ];

  services.resolved = {
    enable = true;
    #dnssec = "true";
    #fallbackDns = [ "1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one" ];
    #dnsovertls = "true";
    settings = {
      Resolve = {
        Domains = [ "home" "~." ];
        MulticastDNS = "false";
      };
    };
  };
}
