{ pkgs, ... }:

{
  imports = [ ../overlays/evdi.nix ];

  # 1. Installe notre paquet displaylink
  environment.systemPackages = [ pkgs.displaylink ];

  # 2. Active les règles udev de notre paquet (corrige la détection)
  services.udev.packages = [ pkgs.displaylink ];

  # Add extra udev rules for stability
  services.udev.extraRules = ''
    # Disable USB3 Link Power Management for DisplayLink devices to improve stability
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="17e9", ATTRS{bDeviceClass}!="09", RUN+="${pkgs.bash}/bin/bash -c 'echo 0 > /sys$devpath/../port/usb3_lpm_permit'"

    # Configure CDC_NCM parameters for the DisplayLink ethernet adapter
    ACTION=="add|move|bind", ATTRS{idVendor}=="17e9", ENV{ID_USB_DRIVER}=="cdc_ncm", ATTR{cdc_ncm/rx_max}="$attr{cdc_ncm/dwNtbInMaxSize}"
    ACTION=="add|move|bind", ATTRS{idVendor}=="17e9", ENV{ID_USB_DRIVER}=="cdc_ncm", ATTR{cdc_ncm/tx_max}="$attr{cdc_ncm/dwNtbOutMaxSize}"
  '';

  # 3. Définit et active le service systemd nous-mêmes (corrige le démarrage)
  systemd.services.displaylink = {
    description = "DisplayLink Manager Service";
    after = [ "systemd-udevd.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.displaylink}/bin/DisplayLinkManager";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
}
