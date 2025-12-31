{
  pkgs, ...
}:

{
  imports = [
    ../common/wayland.nix
  ];

  services.desktopManager.cosmic.enable = true;
  services.system76-scheduler.enable = true;
}
