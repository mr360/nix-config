{ config, pkgs, specialArgs, home-manager, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
      ../../boot/uefi.nix
      ../../host/common.nix
      ../../module/cmd-package.nix
      ../../module/user.nix
      ../../module/libvirt.nix
      ../../module/gui.nix
      ../../module/powersaver.nix
      ../../module/ssh.nix
      ../../module/utility
      ../../module/container.nix
      ../../module/sync.nix
      home-manager.nixosModules.home-manager 
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = {
          inherit (config) networking;        
        };
        home-manager.users.${specialArgs.builderOptions.user.name} = 
        import ../../home-manager/common.nix;
      }
    ];

  builderOptions = specialArgs.builderOptions;
  
  networking.hostName = "storage-r710"; 
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 
      80 443          # internet
      ];
  };

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  nix.gc = {
    automatic = true;
    dates = "yearly";
    options = "--delete-older-than 30d";
  };
  
  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "server";

  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    rebootWindow = {
      lower = "00:00";
      upper = "04:00";
    };
    dates = "yearly";
    flake = specialArgs.flakePath;
    flags = [ 
      "--update-input" 
      "nixpkgs" 
      "--commit-lock-file" 
      ];
  };
  system.stateVersion = "25.05";
}

