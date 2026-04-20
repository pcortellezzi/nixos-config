{
  pkgs, lib, inputs, ...
}:
let
  inherit (inputs) dms hyprland;
in
{
  imports = [ ../overlays/aquamarine.nix ];
  programs.hyprland = {
    enable = true;
    package = hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
  };

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;
  security.pam.services.login.enableGnomeKeyring = true;

  programs.dms-shell = {
    enable = true;
    package = dms.packages.${pkgs.stdenv.hostPlatform.system}.default;

    # Core features
    enableSystemMonitoring = true;
    enableVPN = true;
    enableDynamicTheming = true;
    enableAudioWavelength = true;
    enableCalendarEvents = true;
  };

  # Disable systemd auto-start for DMS — it will be launched via exec-once in Hyprland config
  # to ensure WAYLAND_DISPLAY is available
  systemd.user.services.dms = {
    wantedBy = lib.mkForce [ ];
  };
}
