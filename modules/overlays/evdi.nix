# Override EVDI kernel module with a patched version that signals flip_done
# immediately instead of deferring it until the DisplayLink daemon calls
# grabpix. This prevents EBUSY errors on non-blocking atomic commits.
# Remove this overlay once the fix is upstreamed or no longer needed.
{ ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      linuxPackages_lqx = prev.linuxPackages_lqx.extend (lpFinal: lpPrev: {
        evdi = lpPrev.evdi.overrideAttrs (old: {
          version = "1.14.14-immediate-flip-done";
          src = final.fetchFromGitHub {
            owner = "pcortellezzi";
            repo = "evdi";
            rev = "1b9778ab";
            hash = "sha256-Qf/lSLYlrb9MV3EVu9ILrYRrLbI6rRuA5MGZM/tdggY=";
          };
        });
      });
    })
  ];
}
