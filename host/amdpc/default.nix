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
  time.timeZone = "Australia/Sydney";

  hardware.opengl.enable = true;
  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    rebootWindow = {
      lower = "02:00";
      upper = "04:00";
    };
    dates = "01:00";
    flake = "git+ssh://git@github.com/mr360/nix-config";
    flags = [ 
      "--update-input" 
      "nixpkgs" 
      "--commit-lock-file" 
      ];
  };
  system.stateVersion = "23.05";
}

