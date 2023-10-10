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
        url = "github:NixOS/nixpkgs/release-23.05";
      };
      home-manager = {
        url = "github:nix-community/home-manager/release-23.05";
        inputs.nixpkgs.follows = "nixpkgs";
      };
    };

    outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations = {
        # sudo nixos-rebuild switch --flake .#amd-desktop
        "amd-desktop" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit home-manager;
            custom = {
              user.name = "shady";
              libvirt = {
                enable = true;
                pci_e_devices = "0000:0c:00.0 0000:0c:00.1";
                vendor = "amd";
                };
              gui.enable = true;
              cmdpkgs.enable = true;
              powersaver.enable = false;
            };
          };
          modules = [
            ./host/amdpc/default.nix
          ];
        };
      };
    };
}
