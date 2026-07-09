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
    ../de/plasma.nix
  ];
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver
    ];
  };

  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "vm.vfs_cache_pressure" = 50;
    "kernel.unprivileged_userns_clone" = 1;
  };
}
