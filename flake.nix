{
    description = "NixOS Flake";

    inputs = {
    	nixpkgs.url = "github:NixOS/nixpkgs/release-23.05";
    };

    outputs = { self, nixpkgs, ... }@inputs: {
	nixosConfigurations = {
	    # sudo nixos-rebuild switch --flake .#amd-desktop
	    "amd-desktop" = nixpkgs.lib.nixosSystem {
		system = "x86_64-linux";
    		modules = [
		    ./configuration.nix
		    ./boot/ueif.nix
		    ./host/amd-desktop.nix
		    ./modules/common.nix
		    ./modules/package.nix
		    ./modules/user.nix
		    ./modules/virt.nix
        	];
	    };
	};
     };
}
