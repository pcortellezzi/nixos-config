{
  pkgs, inputs, ...
}:
{
  imports = [
    ../services/bluetooth.nix
    ../services/displaylink.nix
    ../services/solaar.nix
    ../services/pipewire.nix
    ../services/printing.nix
    ../services/tailscale.nix

    ../de/cosmic.nix
    ../de/niri+dms.nix
  ];
}
