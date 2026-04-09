{ pkgs, inputs, ... }:

{
  services.displayManager.cosmic-greeter.enable = false;

  programs.dank-material-shell.greeter = {
    enable = true;
    compositor.name = "hyprland";
    compositor.customConfig = ''
      monitor = desc:LG Electronics LG HDR WQHD 204NTHMB9585, 3440x1440@100, 0x0, 1
      monitor = desc:LG Electronics LG HDR WQHD 204NTABB9600, 3440x1440@100, 0x1440, 1
      monitor = desc:Iiyama North America PL2730Q 1219930721568, 2560x1440@60, 3440x0, 1, transform, 3
      monitor = eDP-1, 2880x1620@120, 4880x2100, 1.80
    '';
  };
}
