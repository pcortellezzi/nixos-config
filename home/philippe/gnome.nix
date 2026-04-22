{ pkgs, lib, ... }:

let
  monitorsXml = pkgs.writeText "monitors.xml" ''
    <monitors version="2">
      <configuration>
        <logicalmonitor>
          <x>0</x>
          <y>0</y>
          <scale>1</scale>
          <primary>yes</primary>
          <monitor>
            <monitorspec>
              <connector>DP-1</connector>
              <vendor>LGE</vendor>
              <product>LG HDR WQHD</product>
              <serial>204NTHMB9585</serial>
            </monitorspec>
            <mode>
              <width>3440</width>
              <height>1440</height>
              <rate>100.000</rate>
            </mode>
          </monitor>
        </logicalmonitor>
        <logicalmonitor>
          <x>0</x>
          <y>1440</y>
          <scale>1</scale>
          <monitor>
            <monitorspec>
              <connector>DP-2</connector>
              <vendor>LGE</vendor>
              <product>LG HDR WQHD</product>
              <serial>204NTABB9600</serial>
            </monitorspec>
            <mode>
              <width>3440</width>
              <height>1440</height>
              <rate>100.000</rate>
            </mode>
          </monitor>
        </logicalmonitor>
        <logicalmonitor>
          <x>3440</x>
          <y>0</y>
          <scale>1</scale>
          <transform>
            <rotation>left</rotation>
            <flipped>no</flipped>
          </transform>
          <monitor>
            <monitorspec>
              <connector>DP-3</connector>
              <vendor>IVM</vendor>
              <product>PL2730Q</product>
              <serial>1219930721568</serial>
            </monitorspec>
            <mode>
              <width>2560</width>
              <height>1440</height>
              <rate>60.000</rate>
            </mode>
          </monitor>
        </logicalmonitor>
        <logicalmonitor>
          <x>4880</x>
          <y>2100</y>
          <scale>1</scale>
          <monitor>
            <monitorspec>
              <connector>eDP-1</connector>
              <vendor>unknown</vendor>
              <product>unknown</product>
              <serial>unknown</serial>
            </monitorspec>
            <mode>
              <width>1920</width>
              <height>1080</height>
              <rate>120.000</rate>
            </mode>
          </monitor>
        </logicalmonitor>
      </configuration>
    </monitors>
  '';
in
{
  home.packages = with pkgs; [
    gnomeExtensions.forge
  ];

  dconf.settings = {
    "org/gnome/shell" = {
      enabled-extensions = [
        "forge@jmmaranan.com"
      ];
    };

    # Forge tiling settings
    "org/gnome/shell/extensions/forge" = {
      window-gap-size = 10;
      window-gap-size-increment = 2;
      window-gap-hidden-on-single = true;
      focus-border-toggle = true;
    };

    # Basic GNOME preferences
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };

    "org/gnome/desktop/wm/preferences" = {
      focus-mode = "sloppy";
    };
  };

  # Seed monitors.xml only if it doesn't exist yet, so GNOME can overwrite it freely.
  home.activation.gnomeMonitors = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -f "$HOME/.config/monitors.xml" ]; then
      install -Dm644 ${monitorsXml} "$HOME/.config/monitors.xml"
    fi
  '';
}
