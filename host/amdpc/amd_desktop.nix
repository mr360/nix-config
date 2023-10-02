({lib, pkgs, ...}: {
  # ==============================================================
  # System Setup
  # ==============================================================
  networking.hostName = "amd-desktop"; 
  networking.networkmanager.enable = true;  
 
  time.timeZone = "Australia/Sydney";

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
})
