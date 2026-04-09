{ pkgs, inputs, ... }:

{
  services.displayManager.cosmic-greeter.enable = false;

  programs.dank-material-shell.greeter = {
    enable = true;
    compositor.name = "hyprland";
  };
}
