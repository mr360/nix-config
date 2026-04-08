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
        url = "github:NixOS/nixpkgs/release-25.05";
      };
      unstable = {
        url = "github:NixOS/nixpkgs/nixos-unstable";
      };
      home-manager = {
        url = "github:nix-community/home-manager/release-25.05";
        inputs.nixpkgs.follows = "nixpkgs";
      };
    };

    outputs = { unstable, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations = {
        # sudo nixos-rebuild switch --flake .#storage-r710
        "storage-r710" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit home-manager;
	    serverUrl = "mr360.me";
	    flakePath = "/home/foxskis/nix-config";
            builderOptions = {
              user.name = "foxskis";
              gui.enable = false;
              cmdpkgs.enable = true;
              powersaver.enable = false;
	      sync = {
	        enable = true;
	      };
              ssh = {
                enable_agent = true;
                enable_server = true;
              };
              container = {
                traefik = { enable = true; };
                jellyfin = true;
		onlyoffice = true;
                nextcloud = true;
                coder = true;
		qbittorrent = true;
		minipaint = true;
		ferdium = true;
		ytdlp = true;
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
      };
    };
}
