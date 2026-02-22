# Override cosmic-comp with a patched version that uses the primary GPU's
# allocator for software outputs (EVDI/DisplayLink) via DrmOutputManager
# set_allocator(), avoiding damage tracking desynchronization.
# Requires a matching smithay fork with set_allocator() support.
# Remove this overlay once the fix is upstreamed or no longer needed.
{ lib, ... }:
{
  nixpkgs.overlays = [
    (final: prev:
      let
        src = final.fetchFromGitHub {
          owner = "pcortellezzi";
          repo = "cosmic-comp";
          rev = "4405c363d88dffff589d84cdfbd115fec595a1a5";
          hash = "sha256-fLnp/H0g1whMhEY677+g8Lfm36dnWPT5nxJ1zAVH2bw=";
        };
      in
      {
        cosmic-comp = prev.cosmic-comp.overrideAttrs (old: {
          version = "1.0-master-evdi-set-allocator";
          inherit src;

          cargoDeps = final.rustPlatform.fetchCargoVendor {
            inherit src;
            name = "cosmic-comp-1.0-master-evdi-set-allocator-vendor";
            hash = "sha256-hCa0sXYdiWYwLx98vHjmgIB9I/Xj2exJNM/+wNhlr4c=";
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
