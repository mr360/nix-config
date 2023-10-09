{ config, pkgs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
      ../../boot/uefi.nix
      ../../modules/cmd-packages.nix
      ../../modules/user.nix
      ../../modules/libvirt.nix
      ../../modules/gui.nix
      ../../modules/powersaver.nix
    ];

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

  # Mount attched ntfs hdd
  # ls -lha /dev/disk/by-uuid
  fileSystems."/mnt/a_drive" =
  { 
    device = "/dev/disk/by-uuid/46AAB89CAAB88A47";
    fsType = "ntfs-3g"; 
    options = ["r"];
  };
  
  fileSystems."/mnt/b_drive" =
  {
    device = "/dev/disk/by-uuid/BACAC99ACAC952F5";
    fsType = "ntfs-3g";
    options = ["r"];
  };


  networking.hostName = "amd-desktop"; 
  networking.networkmanager.enable = true;  
  time.timeZone = "Australia/Sydney";

  hardware.opengl.enable = true;
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "23.05";
}

