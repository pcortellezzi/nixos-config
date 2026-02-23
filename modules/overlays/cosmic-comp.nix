# Override cosmic-comp with a patched version that uses the primary GPU's
# GBM allocator for software outputs (EVDI/DisplayLink) via set_format(),
# moving rendering from llvmpipe to the hardware GPU.
# Remove this overlay once the fix is upstreamed or no longer needed.
{ lib, ... }:
{
  nixpkgs.overlays = [
    (final: prev:
      let
        src = final.fetchFromGitHub {
          owner = "pcortellezzi";
          repo = "cosmic-comp";
          rev = "6f6eef2d502a07d49d334e517a0e2d82380aeaae";
          hash = "sha256-JYvG6/IYqrrXAj1EYwXn+qoLJpvaBPC0aZcC93WhRpE=";
        };
      in
      {
        cosmic-comp = prev.cosmic-comp.overrideAttrs (old: {
          version = "1.0-master-evdi-v2-test";
          inherit src;

          cargoDeps = final.rustPlatform.fetchCargoVendor {
            inherit src;
            name = "cosmic-comp-1.0-master-evdi-v2-test-vendor";
            hash = "sha256-hcQ6u4Aj5Av9T9uX0oDSbJG82g6E8IXcJc4Z2CfoRtg=";
            # Workaround: nix-prefetch-git binary has a version suffix
            # (nix-prefetch-git-26.05pre-git) but fetch-cargo-vendor-util
            # expects "nix-prefetch-git". Add a wrapper with the expected name.
            nativeBuildInputs = [
              (final.writeShellScriptBin "nix-prefetch-git" ''
                exec "${final.nix-prefetch-git}/bin/"nix-prefetch-git-* "$@"
              '')
            ];
          };
        });
      })
  ];
}
