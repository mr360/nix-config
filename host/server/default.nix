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
      ../../module/container.nix
      home-manager.nixosModules.home-manager 
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.${specialArgs.builderOptions.user.name} = 
        import ../../home-manager/common.nix;
      }
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
    allowedTCPPorts = [ 
      22              # ssh
      80 443          # internet
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
    dates = "yearly";
    options = "--delete-older-than 30d";
  };
  
  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "server";

  # Enable Syncthing functionality with appropriate
  # user groups and access, plus host specific folders
  systemd.services.syncthing.serviceConfig.UMask = "0007";
  services = {
    syncthing = {
      enable = true;
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
          "amd-desktop" = { 
	          id = "RWJBHW4-673NVIU-OGXHPTX-4FIKX2T-7QWS2MC-UKKMXT4-HEJPAK5-U2OGHAG"; 
	        };
        };
        folders = {
          "sync" = {
            path = "/mnt/storage/drive/sync";
            devices = [ "amd-desktop" ];
            ignorePerms = true;
            versioning = {
              type = "simple";
              params = {
                keep = "7";
              };
            };
          };
        };
      
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
  #task.fix-syncthing-permissions = {
  #  user = "${config.builderOptions.user.name}";
  #  onCalendar = "*-*-* 4:35:00";
  #  script = let
  #    folders = pkgs.lib.concatMapStringsSep " " (folder: folder.path) (builtins.attrValues config.services.syncthing.folders);
  #    in ''
  #    for FOLDER in ${folders}; do
  #      find "$FOLDER" -type f \( ! -perm -g=rw \) -not -path "*/.st*"  -exec chmod g+rw {} \;
  #      find "$FOLDER" -type d \( ! -perm -g=rwxs \) -not -path "*/.st*" -exec chmod g+rwxs {} \;
  #    done
  #  '';
  #};

  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    rebootWindow = {
      lower = "00:00";
      upper = "04:00";
    };
    dates = "yearly";
    flake = "/home/${config.builderOptions.user.name}/nixos";
    flags = [ 
      "--update-input" 
      "nixpkgs" 
      "--commit-lock-file" 
      ];
  };
  system.stateVersion = "23.11";
}

