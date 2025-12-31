{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    my-nixpkgs = {
      url = "github:pcortellezzi/nixpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    danksearch = {
      url = "github:AvengeMedia/danksearch";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    darkly = {
      url = "github:Bali10050/Darkly";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    kwin-better-blur = {
      url = "github:taj-ny/kwin-effects-forceblur/window-rules";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, agenix, my-nixpkgs, llm-agents, dms, danksearch, plasma-manager, darkly, kwin-better-blur, ... }@inputs:
    let
      stateVersion = "25.11";

      # Generic host configuration
      mkHost = { hostPath, homeModules ? [] }: nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs stateVersion; };
        modules = [
          ./modules/system/auto-update.nix # Automatically update NixOS configuration on boot
          {
            my.auto-update.enable = true; # Enable auto-update for all hosts
            nixpkgs.hostPlatform = "x86_64-linux";
            nixpkgs.overlays = [ my-nixpkgs.overlays.default ];
            nixpkgs.config.allowUnfree = true;
          }
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
              backupFileExtension = "backup";
              users.philippe = {
                imports = [ agenix.homeManagerModules.default ] ++ homeModules;
                age.identityPaths = [ "/home/philippe/.ssh/id_ed25519" ];
              };
              extraSpecialArgs = {
                inherit inputs stateVersion;
              };
            };
          }
        ];
      };
    in
    {
      nixosConfigurations = {
        ser5 = mkHost {
          hostPath = ./hosts/ser5/configuration.nix;
          homeModules = [
            ./home/philippe/common.nix
          ];
        };

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
      };
    };
}
