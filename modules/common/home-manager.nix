{
  config, lib, pkgs, inputs, ...
}:

{
  

  config = {
    home-manager.users.philippe = { pkgs, ... }:
      {
        imports = [ inputs.agenix.homeManagerModules.default ];
      };

    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
  };
}