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
          rev = "fa096dc16798b42c1e2b2940c528de28952ca0ea";
          hash = "sha256-ivofwxxFRwyrfSCKNZy4TjJ2TfAg/0QivDJRSqK7cTA=";
        };
      in
      {
        cosmic-comp = prev.cosmic-comp.overrideAttrs (old: {
          version = "1.0-master-evdi-primary-gpu-rendering";
          inherit src;

          cargoDeps = final.rustPlatform.fetchCargoVendor {
            inherit src;
            name = "cosmic-comp-1.0-master-evdi-primary-gpu-rendering-vendor";
            hash = "sha256-MI8cJzjZd2UeWBESu8xEDYQv0Oa4PRhc4pOCN0zDNO4=";
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
