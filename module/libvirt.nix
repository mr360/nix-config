{ config, lib, pkgs, ... }@args: 

{
  options.builderOptions.libvirt =
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
      type = lib.types.nullOr lib.types.str;
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
  (lib.mkIf (config.builderOptions.libvirt.pci_e_devices != null)
  {
    boot.initrd.availableKernelModules = [ 
      "vfio-pci" 
      ];

    boot.initrd.preDeviceCommands = ''
      DEVS="${config.builderOptions.libvirt.pci_e_devices}"
      for DEV in $DEVS; do
        echo "vfio-pci" > /sys/bus/pci/devices/$DEV/driver_override
      done
      modprobe -i vfio-pci
    '';
    
    boot.kernelParams = [ 
    "kvm.ignore_msrs=1"
    "pcie_aspm=off"
    "${config.builderOptions.libvirt.vendor}_iommu=on"
    ];

    systemd.tmpfiles.rules = [
      "f /dev/shm/looking-glass 0660 ${config.builderOptions.user.name} qemu-libvirtd -"
    ];

    environment.systemPackages = lib.mkBefore [
      pkgs.looking-glass-client 
    ];
  })


  (lib.mkIf (config.builderOptions.libvirt.enable)
  {
    boot.kernelModules = [ 
      "kvm-${config.builderOptions.libvirt.vendor}" 
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
      virt-manager          
    ];

    users.users.${config.builderOptions.user.name} = {
      extraGroups = [
        "libvirtd"
        "qemu-libvirtd" 
        "kvm"
        ]; 
    };

    # Allow VM to run as non-root without ulimit 
    security.pam.loginLimits = [{
      domain = "${config.builderOptions.user.name}";
      type = "soft";
      item = "memlock";
      value = "20000000";
    }
    {
      domain = "${config.builderOptions.user.name}";
      type = "hard";
      item = "memlock";
      value = "20000000";
    }];
  })
];
}
