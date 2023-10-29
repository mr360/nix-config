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
  
  fileSystems."/mnt/storage" =
  { 
    device = "/dev/disk/by-id/scsi-36848f690d9a34c002ab458812f79466a";
    fsType = "ext2";
  };
  
  networking.hostName = "storage-r710"; 
  networking.networkmanager.enable = true;  
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 80 443 52198 9050 4447 8384 22000];
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
      dataDir = "/home/${config.builderOptions.user.name}/sync";
      overrideDevices = true;
      overrideFolders = true;
      devices = {
        "shady-amd" = { id = ""; };
      };
      folders = {
        "Storage" = {        
          path = "/mnt/storage";
          devices = [ "shady-amd"];
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

