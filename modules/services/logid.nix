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
        buttons: (
          {
            # Mic Mute button
            cid: 0xdf;
            action:
            {
              type: "Keypress";
              keys: ["KEY_MICMUTE"];
            };
          },
          {
            # Emoji button
            cid: 0xd9;
            action:
            {
              type: "Keypress";
              keys: ["KEY_HOMEPAGE"];
            };
          },
          {
            # Screenshot button
            cid: 0xc4;
            action:
            {
              type: "Keypress";
              keys: ["KEY_SYSRQ"];
            };
          }
        );
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
