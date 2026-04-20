{ inputs, ... }:

final: prev: {
  aquamarine = inputs.hyprland.inputs.aquamarine.packages.${prev.stdenv.hostPlatform.system}.aquamarine.overrideAttrs (old: {
    patches = (old.patches or []) ++ [ ./aquamarine-evdi.patch ];
  });
}
