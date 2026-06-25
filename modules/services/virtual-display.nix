{ config, lib, pkgs, ... }:

{
  options.my.virtual-display = {
    enable = lib.mkEnableOption "Virtual 1080p display via EDID injection on AMD GPU" // { default = true; };
  };

  config = lib.mkIf config.my.virtual-display.enable {
    hardware.firmware = [ pkgs.virtual-display-edid ];

    boot.kernelParams = [
      "drm_kms_helper.edid_firmware=HDMI-A-1:edid/1920x1080.bin"
    ];
  };
}
