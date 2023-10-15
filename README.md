# nix-config
NixOS configuration: simple system config for my everyday usage. 

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

## Notice
This is not my best work but I hope to improve it over time. I started the journey on the 29/09/23.

