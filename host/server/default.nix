{ config, pkgs, specialArgs, home-manager, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
      ../../boot/uefi.nix
      ../../module/cmd-package.nix
      ../../module/user.nix
      ../../module/libvirt.nix
      ../../module/gui.nix
      ../../module/powersaver.nix
      ../../module/ssh.nix
    ];

  builderOptions = specialArgs.builderOptions;

  networking.hostName = "server-r710"; 
  networking.networkmanager.enable = true;  
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 52198 9050 4447 8384 22000];
    allowedUDPPorts = [ 22000 21027 ];
  };
  time.timeZone = "Australia/Sydney";

  hardware.opengl.enable = true;
  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  # Enable custom syncthing 
  /*services = {
    syncthing = {
      enable = true;
      user = "${config.builderOptions.user.name}";
      configDir = "/home/${config.builderOptions.user.name}/.config/syncthing";
      overrideDevices = true;
      overrideFolders = true;
      devices = {
        "server-r710" = { id = ""; };
      };
      folders = {
        "DriveA" = {        
          path = "/mnt/a_drive";
          devices = [ "server-r710"];
        };
        "DriveB" = {
          path = "/mnt/b_drive";
          devices = [ "server-r710"];
        };

        "Documents" = {
          path = "/home/${config.builderOptions.user.name}/Documents";
          devices = [ "server-r710" ];
          ignorePerms = false;     # By default, Syncthing doesn't sync file permissions. This line enables it for this folder.
        };
      };
      extraOptions = {
        gui = {
          user = "${config.builderOptions.user.name}";
          password = "1234";
        };
      };
    };
  };*/

  system.stateVersion = "23.05";
}

