# nix-config

NixOS configuration: simple system config for my everyday usage.

## Get Started

- Clone current repository to `$HOME` folder & create symlink to `/etc/nixos`
  > sudo ln -s /home/shady/nixos /etc/nixos
- Requires contents from `passwd` repository to be placed within `./dotfile/.cred/`

## Build Installation USB (Live CD)

``` bash
nix build .#nixosConfigurations.live-usb.config.system.build.isoImage
sudo dd bs=4M if=/etc/nixos/result/iso/nixos-23.05.20231014.b85a19a-x86_64-linux.iso of=/dev/sdc conv=fdatasync  status=progress
```

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
Not complete system. I started the journey on the 29/09/23. View docs/tasks.md for more details.

