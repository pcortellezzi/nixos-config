{ config, lib, ... }:

{
  options.my.vkms = {
    enable = lib.mkEnableOption "VKMS virtual display kernel module" // { default = true; };
  };

  config = lib.mkIf config.my.vkms.enable {
    boot.kernelModules = [ "vkms" ];
  };
}
