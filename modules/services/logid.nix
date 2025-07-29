{
  config,
  pkgs,
  ...
}:

let
  logidCfg = pkgs.writeText "logid.cfg" ''
    devices: (
      {
        name: "MX Master 3S";
        smartshift:
        {
          on: false;
        };
        hiresscroll:
        {
          hires: false;
          invert: true;
          target: false;
        };
      },
      {
        name: "MX Keys S";
      }
    );
  '';
in
{
  environment.etc."logid.cfg".source = logidCfg;
  environment.systemPackages = [ pkgs.logiops ];

  systemd.services.logid = {
    enable = true;
    description = "Logitech Configuration Daemon";
    serviceConfig = {
      ExecStart = "${pkgs.logiops}/bin/logid";
      Restart = "always";
      RestartSec = 5;
    };
    wantedBy = [ "multi-user.target" ];
    restartTriggers = [ logidCfg ];
  };

  services.udev.extraRules = ''
    KERNEL=="hidraw*", ATTRS{idVendor}=="046d", TAG+="uaccess"
  '';
}
