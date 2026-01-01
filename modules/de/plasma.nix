{ inputs, pkgs, ... }:

{
  services.desktopManager.plasma6.enable = true;

  environment.systemPackages = [
    inputs.kwin-better-blur.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.darkly.packages.${pkgs.stdenv.hostPlatform.system}.darkly-qt6
    pkgs.kde-rounded-corners
  ];
}