{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    kdePackages.libkscreen
    kdePackages.qttools
    (pkgs.callPackage ../../modules/plasmoids/virtual-display-toggle {})
  ];
}
