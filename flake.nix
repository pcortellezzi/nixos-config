{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
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

    hermes-agent = {
      url = "github:NousResearch/hermes-agent";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hermes-workspace = {
      url = "github:outsourc-e/hermes-workspace";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = { self, nixpkgs, home-manager, agenix, my-nixpkgs, llm-agents, plasma-manager, hermes-agent, hermes-workspace, ... }@inputs:
    let
      stateVersion = "26.05";

      # Generic host configuration
      mkHost = { hostPath, homeModules ? [] }: nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs stateVersion; };
        modules = [
          ./modules/system/auto-update.nix
          ./modules/system/manual-update.nix
          {
            my.auto-update.enable = true;
            my.manual-update.enable = true;
            nixpkgs.hostPlatform = "x86_64-linux";
            nixpkgs.overlays = [ my-nixpkgs.overlays.default ];
            nixpkgs.config.allowUnfree = true;
          }
          hostPath
          agenix.nixosModules.default
          home-manager.nixosModules.home-manager
          {
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
      devShells.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.mkShell {
        packages = with nixpkgs.legacyPackages.x86_64-linux; [ nixd gh ];
      };

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
            ./home/philippe/opencode.nix
            ./home/philippe/codex.nix
            ./home/philippe/vvb.nix
          ];
        };

        flip-cx5 = mkHost {
          hostPath = ./hosts/flip-cx5/configuration.nix;
          homeModules = [
            ./home/philippe/common.nix
            ./home/philippe/desktop.nix
            ./home/philippe/opencode.nix
            ./home/philippe/codex.nix
          ];
        };
      };
    };
}
