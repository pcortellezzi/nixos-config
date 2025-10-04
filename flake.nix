{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    my-nixpkgs = {
      url = "github:pcortellezzi/nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, agenix, my-nixpkgs, nixpkgs-unstable, ... }@inputs:
    let
      # Create a pkgs set with your custom overlays applied
      pkgsWithMyOverlays = import nixpkgs {
        system = "x86_64-linux";
        overlays = [ my-nixpkgs.overlays.default ];
        config.allowUnfree = true;
      };

      pkgs-unstable = import nixpkgs-unstable {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };

      # Generic host configuration
      mkHost = { hostPath, homeModules ? [] }: nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; pkgs = pkgsWithMyOverlays; };
        modules = [
          hostPath
          agenix.nixosModules.default
          home-manager.nixosModules.home-manager
          {
            # The system deploys the user's SSH key.
            age.secrets.philippe_ssh_id_ed25519 = {
              file = ./secrets/philippe_ssh_id_ed25519.age;
              path = "/home/philippe/.ssh/id_ed25519";
              owner = "philippe";
              mode = "600";
              symlink = false;
            };

            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.philippe = {
                imports = [ agenix.homeManagerModules.default ] ++ homeModules;
                age.identityPaths = [ "/home/philippe/.ssh/id_ed25519" ];
              };
              extraSpecialArgs = { inherit pkgs-unstable; };
            };
          }
        ];
      };
    in
    {
      nixosConfigurations = {
        vvb = mkHost {
          hostPath = ./hosts/vvb/configuration.nix;
          homeModules = [
            ./home/philippe/common.nix
            ./home/philippe/desktop.nix
          ];
        };

        flip-cx5 = mkHost {
          hostPath = ./hosts/flip-cx5/configuration.nix;
          homeModules = [
            ./home/philippe/common.nix
            ./home/philippe/desktop.nix
          ];
        };

        ser5 = mkHost {
          hostPath = ./hosts/ser5/configuration.nix;
          homeModules = [
            ./home/philippe/common.nix
          ];
        };
      };
    };
}