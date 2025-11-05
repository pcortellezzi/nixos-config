{
  pkgs, ...
}:

{
  imports = [
    ../services/bluetooth.nix
    ../services/displaylink.nix
    ../services/logid.nix
    ../services/pipewire.nix
    ../services/printing.nix
    ../services/tailscale.nix
  ];

  services.xserver.enable = true;

  programs.dankMaterialShell.greeter = {
    enable = true;
    compositor.name = "niri";
  };

  environment.variables = {
    KWIN_DRM_PREFER_COLOR_DEPTH = "24";
  };

  services.desktopManager.plasma6.enable = true;
}
