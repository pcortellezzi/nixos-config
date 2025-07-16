{
  config, pkgs, inputs, ...
}:

{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = { inherit inputs; osConfig = config; };
  home-manager.users.philippe = import ../home/philippe.nix;
}
