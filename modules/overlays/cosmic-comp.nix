# Override cosmic-comp with a patched version that bypasses llvmpipe for
# software outputs (EVDI/DisplayLink) by using the primary GPU's allocator.
# Follows smithay's anvil primary render fallback pattern (PR #1680).
# Remove this overlay once the fix is upstreamed or no longer needed.
{ ... }:
{
  nixpkgs.overlays = [
    (final: prev:
      let
        src = final.fetchFromGitHub {
          owner = "pcortellezzi";
          repo = "cosmic-comp";
          rev = "fb7df317820bf9b2bfbd24a3b79e1d861bd3552b";
          hash = "sha256-hg500YktBENmqLppp3Ew2s1sE/l3H8sqIz9Z+iXgkcI=";
        };
      in
      {
        cosmic-comp = prev.cosmic-comp.overrideAttrs (old: {
          version = "1.0-master-evdi-cursor-planes";
          inherit src;

          cargoDeps = final.rustPlatform.fetchCargoVendor {
            inherit src;
            name = "cosmic-comp-1.0-master-evdi-cursor-planes-vendor";
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
