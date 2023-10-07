{ config, pkgs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
      ../../boot/uefi.nix
      ../../modules/common.nix
      ../../modules/package.nix
      ../../modules/user.nix
      ../../modules/libvirt.nix	
    ];

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  networking.hostName = "amd-desktop"; 
  networking.networkmanager.enable = true;  
 
  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.desktopManager.lxqt.enable = true;
  services.xserver.excludePackages = [ 
    pkgs.xterm
  ];
  environment.lxqt.excludePackages = [
    pkgs.lxqt.lximage-qt
    pkgs.lxqt.screengrab
  ];

  # Configure keymap in X11
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "eurosign:e,caps:escape";

  system.stateVersion = "23.05";
}

