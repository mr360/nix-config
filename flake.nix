{
    description = "NixOS Flake";
    
    nixConfig = {
      experimental-features = [ "nix-command" "flakes" ];
      substituters = [
        "https://cache.nixos.org/"
      ];

      extra-substituters = [
        # Nix community's cache server
        "https://nix-community.cachix.org"
      ];
      extra-trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };

    inputs = {
    	nixpkgs = {
        url = "github:NixOS/nixpkgs/release-23.11";
      };
      unstable = {
        url = "github:NixOS/nixpkgs/nixos-unstable";
      };
      home-manager = {
        url = "github:nix-community/home-manager/release-23.11";
        inputs.nixpkgs.follows = "nixpkgs";
      };
    };

    outputs = { unstable, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations = {
        # sudo nixos-rebuild switch --flake .#amd-desktop
        "amd-desktop" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit home-manager;
            builderOptions = {
              user.name = "shady";
              libvirt = {
                enable = true;
                pci_e_devices = "0000:0c:00.0 0000:0c:00.1";
                vendor = "amd";
                };
              gui.enable = true;
              cmdpkgs.enable = true;
              powersaver.enable = false;
              ssh = {
                enable_agent = true;
                enable_server = false;
              };
              container = {
                idrac6 = true;
              };
            };
          };
          modules = [
            ./host/amdpc/default.nix
            ({ config, pkgs, ... }: {
              nixpkgs.overlays = [(final: prev: {
                unstable = import unstable;
              })];
            })
          ];
        };
        # sudo nixos-rebuild switch --flake .#storage-r710
        "storage-r710" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit home-manager;
            builderOptions = {
              user.name = "foxskis";
              gui.enable = false;
              cmdpkgs.enable = true;
              powersaver.enable = false;
              ssh = {
                enable_agent = true;
                enable_server = true;
              };
              container = {
                bind9 = true;
                jellyfin = true;
                code = true;
                nextcloud = true;
              };
            };
          };
          modules = [
            ./host/server/default.nix
            ({ config, pkgs, ... }: {
              nixpkgs.overlays = [(final: prev: {
                unstable = import unstable;
              })];
            })
          ];
        };
        # nix build .#nixosConfigurations.live-usb.config.system.build.isoImage
        "live-usb" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            builderOptions = {
              user.name = "live";
              gui.enable = false;
              cmdpkgs.enable = true;
              powersaver.enable = false;
              ssh = {
                enable_agent = true;
                enable_server = true;
              };
            };
          };
          modules = [
            (nixpkgs + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix")
            ./host/liveusb/default.nix
            ({ config, pkgs, ... }: {
              nixpkgs.overlays = [(final: prev: {
                unstable = import unstable;
              })];
            })
          ];
        };
      };
    };
}
