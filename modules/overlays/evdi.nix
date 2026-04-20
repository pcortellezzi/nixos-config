# EVDI overlay removed - using stock evdi from nixpkgs
# If needed again, restore from git history
{ ... }:
{
  nixpkgs.overlays = [
    # No custom evdi overlay - using stock version from linuxPackages_zen
  ];
}