# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # =================================================================
  # Misc Options
  # =================================================================
  nixpkgs.config.allowUnfree = true;
  hardware.opengl.enable = true;
  programs.dconf.enable = true; 
  boot.supportedFilesystems = [ "ntfs" ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # =================================================================
  # GPU Passthrough 
  # =================================================================
  boot.initrd.availableKernelModules = [ 
    "vfio-pci" 
    ];

  boot.initrd.preDeviceCommands = ''
    DEVS="0000:0c:00.0 0000:0c:00.1"
    for DEV in $DEVS; do
      echo "vfio-pci" > /sys/bus/pci/devices/$DEV/driver_override
    done
    modprobe -i vfio-pci
  '';
  
  boot.kernelParams = [ 
   "amd_iommu=on" 
   "pcie_aspm=off"
   ];
  boot.kernelModules = [ "kvm-amd" ];

  virtualisation.libvirtd = {
    enable = true;
    qemuOvmf = true;
    qemuRunAsRoot = false;
    onBoot = "ignore";
    onShutdown = "shutdown";
  };

  virtualisation.spiceUSBRedirection.enable = true;

  systemd.tmpfiles.rules = [
    "f /dev/shm/scream 0660 shady qemu-libvirtd -"
    "f /dev/shm/looking-glass 0660 shady qemu-libvirtd -"
  ];

  systemd.user.services.scream-ivshmem = {
    enable = true;
    description = "Scream IVSHMEM";
    serviceConfig = {
      ExecStart = "${pkgs.scream}/bin/scream-ivshmem-pulse /dev/shm/scream";
      Restart = "always";
    };
    wantedBy = [ "multi-user.target" ];
    requires = [ "pulseaudio.service" ];
  };

  # ==============================================================
  # Use the systemd-boot EFI boot loader.
  # ==============================================================
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ==============================================================
  # System Setup
  # ==============================================================
  # Configure network
  networking.hostName = "amd-desktop"; 
  # networking.wireless.enable = true;  
  networking.networkmanager.enable = true;  

  # Set timezone
  time.timeZone = "Australia/Sydney";

  # Enable proxy
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";


  # Enable the X11 windowing system.
   services.xserver.enable = true;
   services.xserver.desktopManager.lxqt.enable = true;
   services.xserver.excludePackages = [ 
     pkgs.xterm
     ];
   environment.lxqt.excludePackages = [
     pkgs.lxqt.lximage-qt
     pkgs.lxqt.screengrab
     ];

  # Configure keymap in X11
   services.xserver.layout = "us";
   services.xserver.xkbOptions = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
   sound.enable = true;
   hardware.pulseaudio.enable = true;

  # =================================================================
  # Main User Setup
  # =================================================================
   users.users.shady = {
    isNormalUser = true;
     extraGroups = [ "wheel" "libvirtd" ];
     packages = with pkgs; [
       firefox
       google-chrome
       vscode
     ];
     initialPassword = "1234";
   };

  users.mutableUsers = false;
  
  # =================================================================
  # System Packages 
  # =================================================================
  # List packages installed in system profile. To search, run:
  # $ nix search wget
   environment.systemPackages = with pkgs; [
     git
     neovim 
     wget
     tmux
     tree
     gdb
     jq
     p7zip
     python3
     looking-glass-client # V
     scream               # V
     virtmanager          # V
     wineWowPackages.stable # MO
     wine                   # MO
     winetricks             # MO
     hexedit
   ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}

