# Overlay to patch aquamarine input for EVDI/DisplayLink compatibility
{ inputs, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      aquamarine = inputs.aquamarine.packages.${prev.stdenv.hostPlatform.system}.aquamarine.overrideAttrs (old: {
        patches = (old.patches or []) ++ [ ./aquamarine-evdi.patch ];
      });
    })
  ];
}
