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
      ../../module/container.nix 
      ../../module/utility     
      home-manager.nixosModules.home-manager 
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.${specialArgs.builderOptions.user.name} = 
        import ../../home-manager/amdpc/default.nix;
      }
    ];

  builderOptions = specialArgs.builderOptions;

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
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 
      80 443          # internet 
      9050 4447 8384  # popcorn-time
      52198           # qbittorrent 
      22000           # syncthing
      ];
    allowedUDPPorts = [ 
      22000 21027     # syncthing
      ];  
  };
  time.timeZone = "Australia/Sydney";

  hardware.opengl.enable = true;
  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  nix.gc = {
    automatic = true;
    dates = "monthly";
    options = "--delete-older-than 30d";
  };

  # Enable Syncthing functionality with appropriate
  # user groups and access, plus host specific folders
  systemd.services.syncthing.serviceConfig.UMask = "0007";
  services = {
    syncthing = {
      enable = true;
      relay.enable = false;
      user = "${config.builderOptions.user.name}";
      group = "users";
      configDir = "/home/${config.builderOptions.user.name}/.config/syncthing";
      dataDir = "/home/${config.builderOptions.user.name}/.config/syncthing";
      overrideDevices = true;
      overrideFolders = true;
      cert = "/etc/nixos/dotfile/.cred/user/${config.builderOptions.user.name}/syncthing/cert.pem";
      key = "/etc/nixos/dotfile/.cred/user/${config.builderOptions.user.name}/syncthing/key.pem";
      settings = {
        devices = {
          "storage-r710" = { id = "NFEK5HE-FNVPJ2F-BNGIPK3-QAU2HRO-RQQULMV-J3AMFKQ-4FAFLNR-UXIBWA4"; };
        };
        folders = {
          "sync" = {
            path = "/home/${config.builderOptions.user.name}/sync";
            devices = [ "storage-r710" ];
            ignorePerms = true;
          };
        };
        gui.insecureSkipHostcheck = true;
        gui.apikey = "qUTatb5NdbbeC5EofGgHZqtkjbPu6APN";
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

  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    rebootWindow = {
      lower = "00:00";
      upper = "04:00";
    };
    dates = "weekly";
    flake = "/home/${config.builderOptions.user.name}/nixos";
    flags = [ 
      "--update-input" 
      "nixpkgs" 
      "--commit-lock-file" 
      ];
  };
  system.stateVersion = "23.11";
}

