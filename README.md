# nix-config
NixOS configuration : simple system config for my everyday usage

boot
- uefi.nix
- efi.nix

host
- amd_desktop.nix

modules
- common.nix
- user.nix
- virt.nix

vm
 - win10-1080ti.virt.xml

TODO: dotfiles, cred, home-manager, nixpkg, ...

fc-cache -f -v          // Rebuild font cache after font addition
openbox --reconfigure   // Restart after changes 