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

    ../de/cosmic.nix
  ];
}
