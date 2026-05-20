{ pkgs, ... }:

{
  # Désactive automatiquement le WiFi quand une connexion Ethernet (RJ45) est active.
  # Réactive le WiFi quand le câble est débranché.
  networking.networkmanager.dispatcherScripts = [
    {
      source = pkgs.writeShellScript "ethernet-wifi-switch" ''
        INTERFACE=$1
        EVENT=$2

        # Ne concerne que les interfaces Ethernet
        DEVICE_TYPE=$(nmcli -t -f GENERAL.TYPE device show "$INTERFACE" 2>/dev/null | cut -d: -f2)
        if [ "$DEVICE_TYPE" != "ethernet" ]; then
          exit 0
        fi

        if [ "$EVENT" = "up" ]; then
          nmcli radio wifi off
        elif [ "$EVENT" = "down" ]; then
          # Réactive le WiFi seulement si aucune autre interface Ethernet n'est connectée
          if ! nmcli -t -f TYPE,STATE device status | grep -q "^ethernet:connected$"; then
            nmcli radio wifi on
          fi
        fi
      '';
      type = "basic";
    }
  ];
}
