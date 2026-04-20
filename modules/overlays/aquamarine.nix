# Overlay to patch aquamarine for EVDI/DisplayLink compatibility
# This forces EVDI connectors to be detected by Hyprland
{ ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      aquamarine = prev.aquamarine.overrideAttrs (old: {
        patches = (old.patches or []) ++ [ ./aquamarine-evdi.patch ];
        
        # Add some debug logging during build
        preBuild = ''
          ${old.preBuild or ""}
          echo "=== Building aquamarine with EVDI patch ==="
          echo "Patches applied:"
          ls -la *.patch 2>/dev/null || echo "No patches directory"
        '';
      });
    })
  ];
}
