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

  services.displayManager.cosmic-greeter.enable = true;
  services.desktopManager.cosmic.enable = true;
  services.system76-scheduler.enable = true;
}
