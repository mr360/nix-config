{ config, lib, pkgs, ... }@args: 

{
  options.custom.libvirt =
  {
    enable = lib.mkOption {
      default = false;
      example = true;
      type = lib.types.bool;
      description = ''
        Define whether to enable libvirt.
      '';
    };

    pci_e_devices = lib.mkOption {
      default = null;
      example = "0000:0c:00.0 0000:0c:00.1";
      type = lib.types.str;
      description = ''
        String list of PCI-E devices to passthrough.
        If none are supplied -- passthrough is disabled
      '';
    };

    vendor = lib.mkOption {
      default = null;
      example = "amd";
      type = lib.types.str;
      description = ''
        Define CPU vendor e.g Intel or AMD
      '';
    };  
  };

  config = lib.mkMerge [
  (lib.mkIf (config.custom.libvirt.pci_e_devices != null)
  {
    boot.initrd.availableKernelModules = [ 
      "vfio-pci" 
      ];

    boot.initrd.preDeviceCommands = ''
      DEVS="${config.custom.libvirt.pci_e_devices}"
      for DEV in $DEVS; do
        echo "vfio-pci" > /sys/bus/pci/devices/$DEV/driver_override
      done
      modprobe -i vfio-pci
    '';
    
    boot.kernelParams = [ 
    "kvm.ignore_msrs=1"
    "pcie_aspm=off"
    "${config.custom.libvirt.vendor}_iommu=on"
    ];

    systemd.tmpfiles.rules = [
      "f /dev/shm/scream 0660 ${config.custom.user.name} qemu-libvirtd -"
      "f /dev/shm/looking-glass 0660 ${config.custom.user.name} qemu-libvirtd -"
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

    environment.systemPackages = lib.mkBefore [
      pkgs.looking-glass-client 
      pkgs.scream               
    ];
  })


  (lib.mkIf (config.custom.libvirt.enable)
  {
    boot.kernelModules = [ 
      "kvm-${config.custom.libvirt.vendor}" 
      ];

    virtualisation.libvirtd = {
      enable = true;
      qemu.ovmf.enable = true;
      qemu.runAsRoot = false;
      onBoot = "ignore";
      onShutdown = "shutdown";
    };

    virtualisation.spiceUSBRedirection.enable = true;

    # Required for virtmanager settings tostick
    programs.dconf.enable = true; 
    
    environment.systemPackages = with pkgs; [
      virtmanager          
    ];

    users.users.${config.custom.user.name} = {
      extraGroups = [
        "libvirtd"
        "qemu-libvirtd" 
        "kvm"
        ]; 
    };

    # Allow VM to run as non-root without ulimit 
    security.pam.loginLimits = [{
      domain = "${config.custom.user.name}";
      type = "soft";
      item = "memlock";
      value = "20000000";
    }
    {
      domain = "${config.custom.user.name}";
      type = "hard";
      item = "memlock";
      value = "20000000";
    }];
  })
];
}
