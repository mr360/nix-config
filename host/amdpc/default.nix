{ config, pkgs, specialArgs, home-manager, ... }:

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
      home-manager.nixosModules.home-manager 
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.${specialArgs.custom.user.name} = 
        import ../../home-manager/amdpc/default.nix;
        #home-manager.extraSpecialArgs to pass arguments to home.nix
      }
    ];

  custom = specialArgs.custom;

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

  system.stateVersion = "23.05";
}

