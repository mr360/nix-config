({lib, pkgs, ...}: {
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

  programs.dconf.enable = true # Allow settings modf for Virt-Manager
  environment.systemPackages = with pkgs; [
     looking-glass-client 
     scream               
     virtmanager          
  ];

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
};
