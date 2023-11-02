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
      ../../module/utility
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

  # Enable Nextcloud hosting service to track
  # documents and files e.g movies tv shows music
  users.users."${config.builderOptions.user.name}".extraGroups = [ "nextcloud" ];
  users.users.nextcloud.extraGroups = [ "users" ];
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud27;
    hostName = "192.168.1.102";
    home = "/mnt/storage/nextcloud";
    database.createLocally = true;
    config = {
      dbtype = "sqlite";
      adminuser = "${config.builderOptions.user.name}";
      adminpassFile = "${pkgs.writeText "adminpass" "1234"}";
    };
    https = false;
    autoUpdateApps.enable = true;
    autoUpdateApps.startAt = "05:00:00";
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
        "LtsData2" = {
          path = "/mnt/storage/drive/LtsData2";
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
  
  # Task to set group permissions for files created by syncthing
  # Allows user and nextcloud group to rw files and directories
  task.fix-syncthing-permissions = {
    user = "${config.builderOptions.user.name}";
    onCalendar = "*-*-* 18:00:00";
    script = let
      folders = pkgs.lib.concatMapStringsSep " " (folder: folder.path) (builtins.attrValues config.services.syncthing.folders);
      in ''
      for FOLDER in ${folders}; do
        find "$FOLDER" -type f \( ! -group syncthing -or ! -perm -g=rw \) -not -path "*/.st*" -exec chgrp syncthing {} \; -exec chmod g+rw {} \;
        find "$FOLDER" -type d \( ! -group syncthing -or ! -perm -g=rwxs \) -not -path "*/.st*" -exec chgrp syncthing {} \; -exec chmod g+rwxs {} \;
      done
    '';
  };

  system.stateVersion = "23.05";
}

