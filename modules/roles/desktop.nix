{
  pkgs, inputs, ...
}:
{
  imports = [
    ../system/plymouth.nix
    ../services/bluetooth.nix
    ../services/displaylink.nix
    ../services/solaar.nix
    ../services/pipewire.nix
    ../services/printing.nix
    ../services/tailscale.nix

    ../de/greeter.nix
    ../de/cosmic.nix
    ../de/niri+dms.nix
    ../de/plasma.nix
  ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
}
