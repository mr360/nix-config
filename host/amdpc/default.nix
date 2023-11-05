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
  
  # Hack: XServer prefers DP over HDMI for primary monitor
  # so set HDMI display as primary rather than secondary
  systemd.user.services.resetDisplay = {
      script = ''
          sleep 1 && ${pkgs.xorg.xrandr}/bin/xrandr --output HDMI-1 --off && ${pkgs.xorg.xrandr}/bin/xrandr --auto && ${pkgs.xorg.xrandr}/bin/xrandr --output HDMI-1 --primary  --output DP-1  --right-of HDMI-1
      '';
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
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
      overrideDevices = true;
      overrideFolders = true;
      devices = {
        "storage-r710" = { id = "NFEK5HE-FNVPJ2F-BNGIPK3-QAU2HRO-RQQULMV-J3AMFKQ-4FAFLNR-UXIBWA4"; };
      };
      folders = {
        "LtsData" = {        
          path = "/mnt/a_drive/KeepOOO";
          devices = [ "storage-r710"];
        };
        "LtsData2" = {        
          path = "/mnt/b_drive/KeepOOO1";
          devices = [ "storage-r710"];
        };
        "Documents" = {
          path = "/home/${config.builderOptions.user.name}/Documents";
          devices = [ "storage-r710" ];
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

  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    rebootWindow = {
      lower = "00:00";
      upper = "04:00";
    };
    dates = "monthly";
    flake = "/home/${config.builderOptions.user.name}/nixos";
    flags = [ 
      "--update-input" 
      "nixpkgs" 
      "--commit-lock-file" 
      ];
  };
  system.stateVersion = "23.05";
}

