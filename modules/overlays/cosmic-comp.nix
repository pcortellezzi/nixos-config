# Override cosmic-comp with a patched version that uses hardware GPU
# rendering for EVDI/DisplayLink outputs instead of llvmpipe (CPU).
# Remove this overlay once the fix is upstreamed or no longer needed.
{ ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      cosmic-comp = prev.cosmic-comp.overrideAttrs (old: {
        version = "1.0.5-evdi-gpu";

        src = final.fetchFromGitHub {
          owner = "pcortellezzi";
          repo = "cosmic-comp";
          rev = "eb247015";
          hash = "sha256-hRZsFcYwiGkV0UfGAf6E2uomGvFb7BdU3L/p7CvGbxI=";
        };

        # Same Cargo.lock as epoch-1.0.5, so cargoHash is unchanged.
      });
    })
  ];
}
