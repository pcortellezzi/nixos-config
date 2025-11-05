{ config, pkgs, dankMaterialShell, pkgs-unstable, ... }:

{
  imports = [
    dankMaterialShell.homeModules.dankMaterialShell.default
    dankMaterialShell.homeModules.dankMaterialShell.niri
  ];

  programs.dankMaterialShell = {
    enable = true;

    enableSystemd = true;
    enableSystemMonitoring = true;
    enableClipboard = true;
    enableVPN = true;
    enableBrightnessControl = true;
    enableColorPicker = true;
    enableDynamicTheming = true;
    enableAudioWavelength = true;
    enableCalendarEvents = true;
    enableSystemSound = true;

    quickshell.package = pkgs-unstable.quickshell;

    default.settings = {
      theme = "dark";
      dynamicTheming = true;
      # Add any other settings here
    };

    default.session = {
      # Session state defaults
    };

    niri = {
      enableKeybinds = true;
    };
  };
  
}
