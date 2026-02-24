# Override cosmic-comp with a patched version that uses the primary GPU's
# allocator for software outputs (EVDI/DisplayLink), following the pattern
# from smithay's anvil (PR #1680 "Primary render fallback").
# Remove this overlay once the fix is upstreamed or no longer needed.
{ lib, ... }:
{
  nixpkgs.overlays = [
    (final: prev:
      let
        src = final.fetchFromGitHub {
          owner = "pcortellezzi";
          repo = "cosmic-comp";
          rev = "2b78b238abaa58edadc81ba0d7f1dcf2314223bc";
          hash = "sha256-ZnSs5pa1PSt8K7yptD9n6BJ4+DXMTfchZLTq10YciJE=";
        };
      in
      {
        cosmic-comp = prev.cosmic-comp.overrideAttrs (old: {
          version = "1.0-master-evdi-primary-gpu-fallback";
          inherit src;

          cargoDeps = final.rustPlatform.fetchCargoVendor {
            inherit src;
            name = "cosmic-comp-1.0-master-evdi-primary-gpu-fallback-vendor";
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
