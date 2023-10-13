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
├── wallpaper
│   └── wp9205370-wallpapers.jpg
├── README.md
├── libvirt.md
└── win10-1080ti.virt.xml
```


## NixOS Flake: 
- TODO: Add SSH agent support using user.users.shady.authorizationssh

## Home Manager (User Settings)
- Implement user settings for editors and refine window controls (iterative)

## Custom nixpkgs
- TODO: Understand how to develop custom packages & overlays

## Virtualisation (PCI-E Passthrough)
- FUTURE: VM drive on physical disk/partition rather than raw image


