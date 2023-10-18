{ config, pkgs, specialArgs, home-manager, ... }:

{
  imports =
    [ 
      ../../module/cmd-package.nix
      ../../module/user.nix
      ../../module/libvirt.nix
      ../../module/gui.nix
      ../../module/powersaver.nix
      ../../module/ssh.nix
    ];

  builderOptions = specialArgs.builderOptions;
  
  networking.hostName = "nix-live"; 
  networking.networkmanager.enable = if config.networking.wireless.enable then false else true;
  time.timeZone = "Australia/Sydney";

  hardware.opengl.enable = true;
  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  system.stateVersion = "23.05";
}

