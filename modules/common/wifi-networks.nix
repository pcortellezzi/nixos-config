{
  config,
  lib,
  pkgs,
  ...
}:

{
  age.secrets.wifi_Livebox-7360_EXT = {
    file = ../../secrets/wifi_Livebox-7360_EXT.age;
    owner = "root";
    group = "root";
    mode = "0400";
  };

  networking.networkmanager.ensureProfiles.profiles = {
    "Livebox-7360_EXT" = {
      connection = {
        id = "Livebox-7360_EXT";
        
        type = "wifi";
      };
      wifi = {
        ssid = "Livebox-7360_EXT";
        mode = "infrastructure";
      };
      "802-11-wireless-security" = {
        key-mgmt = "wpa-psk";
        psk = config.age.secrets.wifi_Livebox-7360_EXT.path;
      };
      ipv4 = {
        method = "auto";
      };
      ipv6 = {
        method = "auto";
      };
    };
  };
}
