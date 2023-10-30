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
    device = "/dev/disk/by-uuid/55689d40-7584-4040-970c-be406ab09ac9";
    fsType = "ext4";
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

  # Enable Syncthing functionality with appropriate
  # user groups and access, plus host specific folders
  systemd.services.syncthing.serviceConfig.UMask = "0007";
  services = {
    syncthing = {
      enable = true;
      user = "${config.builderOptions.user.name}";
      group = "users";
      configDir = "/home/${config.builderOptions.user.name}/.config/syncthing";
      overrideDevices = true;
      overrideFolders = true;
      devices = {
        "amd-desktop" = { 
	        id = "RWJBHW4-673NVIU-OGXHPTX-4FIKX2T-7QWS2MC-UKKMXT4-HEJPAK5-U2OGHAG"; 
	      };
      };
      folders = {
        "Documents" = {
          path = "/mnt/storage/drive/Documents";
          devices = [ "amd-desktop" ];
          ignorePerms = true;
          versioning = {
            type = "simple";
            params = {
              keep = "7";
            };
          };
        };
        "LtsData" = {
          path = "/mnt/storage/drive/LtsData";
          devices = [ "amd-desktop" ];
          ignorePerms = true;
	      };
      };
      extraOptions = {
        gui.insecureSkipHostcheck = true;
        options = {
          relaysEnabled = false;
          natEnabled = true;
          globalAnnounceEnabled = false;
          localAnnounceEnabled = true;
          urAccepted = -1;
        };
      }; 
    };
  };

  system.stateVersion = "23.05";
}

