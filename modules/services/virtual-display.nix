{ config, lib, pkgs, ... }:

let
  cfg = config.my.virtual-display;
in
{
  options.my.virtual-display = {
    enable = lib.mkEnableOption "vkms virtual display (load kernel module at boot)" // { default = true; };
  };

  config = lib.mkIf cfg.enable {
    boot.kernelModules = [ "vkms" ];

    environment.systemPackages = with pkgs; [
      kdePackages.libkscreen
      kdePackages.qttools
      (pkgs.callPackage ../../modules/plasmoids/virtual-display-toggle {})
    ];
  };
}
