{
  pkgs, inputs, ...
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

  environment.variables = {
    KWIN_DRM_PREFER_COLOR_DEPTH = "24";
  };

  services.desktopManager.plasma6.enable = true;


  services.displayManager.cosmic-greeter.enable = true;
  services.desktopManager.cosmic.enable = true;
}
