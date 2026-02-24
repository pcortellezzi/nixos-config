# Override cosmic-comp with a patched version that uses the primary GPU's
# GBM allocator for software outputs (EVDI/DisplayLink) via set_allocator(),
# testing whether this approach works with stock EVDI.
# Remove this overlay once the fix is upstreamed or no longer needed.
{ lib, ... }:
{
  nixpkgs.overlays = [
    (final: prev:
      let
        src = final.fetchFromGitHub {
          owner = "pcortellezzi";
          repo = "cosmic-comp";
          rev = "1c89b854ee1c0c862ae5a51a8e3777c7523c2bcd";
          hash = "sha256-LElBq/1+6q5RxAHvxmGj9amUZ7vZYtK/xnG0JlghMUs=";
        };
      in
      {
        cosmic-comp = prev.cosmic-comp.overrideAttrs (old: {
          version = "1.0-master-evdi-set-allocator-test";
          inherit src;

          cargoDeps = final.rustPlatform.fetchCargoVendor {
            inherit src;
            name = "cosmic-comp-1.0-master-evdi-set-allocator-test-vendor";
            hash = "sha256-Ax7vWzjauAuWRahjuccADTjtpe+fmNNUdItWh8J03Kc=";
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
