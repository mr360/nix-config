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
    	nixpkgs.url = "github:NixOS/nixpkgs/release-23.05";
    };

    outputs = { self, nixpkgs, ... }@inputs: {
	nixosConfigurations = {
	    # sudo nixos-rebuild switch --flake .#amd-desktop
	    "amd-desktop" = nixpkgs.lib.nixosSystem {
		system = "x86_64-linux";
    		modules = [
		    ./host/amdpc/default.nix
        	];
	    };
	};
     };
}
