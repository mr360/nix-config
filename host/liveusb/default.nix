{ lib, config, pkgs, specialArgs, home-manager, ... }:

{
  imports =
    [ 
      ../../module/cmd-package.nix
      ../../host/common.nix
      ../../module/user.nix
      ../../module/libvirt.nix
      ../../module/gui.nix
      ../../module/powersaver.nix
      ../../module/ssh.nix
      ../../module/sync.nix
    ];

  builderOptions = specialArgs.builderOptions;
  
  isoImage.contents = [
    {
      source = /etc/nixos/dotfile/.cred;
      target = "/etc/nixos/dotfile/.cred";
    }
  ];

  networking.hostName = "live-usb"; 

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  system.stateVersion = "25.05";
}

