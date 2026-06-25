{ config, lib, pkgs, ... }:

{
  options.my.virtual-display = {
    enable = lib.mkEnableOption "Virtual 1080p display via EDID injection on AMD GPU" // { default = true; };
  };

  config = lib.mkIf config.my.virtual-display.enable {
    hardware.firmware = [ pkgs.virtual-display-edid ];

    # EDID must be in initrd so DRM can load it early during connector init
    boot.initrd.extraFiles."/lib/firmware/edid/1920x1080.bin" = {
      source = "${pkgs.virtual-display-edid}/lib/firmware/edid/1920x1080.bin";
    };

    boot.kernelParams = [
      # Enable the HDMI-A-1 connector (EDID provides 1920x1080 mode)
      "video=HDMI-A-1:1920x1080M@60e"
      "drm_kms_helper.edid_firmware=HDMI-A-1:edid/1920x1080.bin"
    ];
  };
}
