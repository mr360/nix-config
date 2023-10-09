# nix-config
NixOS configuration: simple system config for my everyday usage

## Structure
```
├── flake.lock
├── flake.nix
├── boot
│   └── uefi.nix
├── host
│   ├── amdpc
│   │   ├── default.nix
│   │   └── hardware-configuration.nix
│   └── vmware
├── modules
│   ├── cmd-packages.nix
│   ├── gui.nix
│   ├── libvirt.nix
│   ├── nixpkgs
│   ├── powersaver.nix
│   └── user.nix
├── README.md
├── libvirt.md
└── win10-1080ti.virt.xml
```


## NixOS Flake: 
- Required: Add SSH agent support using user.users.shady.authorizationssh

## Home Manager (User Settings)
- Required: Integrate and setup HM

## Custom nixpkgs
- Understand how to develop custom packages

## Virtualisation (PCI-E Passthrough)
- Future Goal: VM drive on physical disk/partition rather than raw image


