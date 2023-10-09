# nix-config
NixOS configuration : simple system config for my everyday usage

# TODO: 
- Add SSH agent support (user.users.sshkey"
- Home Manager
- 

## Structure
├── boot
│   └── uefi.nix
├── flake.lock
├── flake.nix
├── host
│   └── amdpc
│       ├── default.nix
│       └── hardware-configuration.nix
├── modules
│   ├── common.nix
│   ├── package.nix
│   ├── user.nix
│   └── virt.nix
├── README.md
└── win10-1080ti.virt.xml


## Virtualisation (PCI-E Passthrough)
- TODO: VM drive on physical disk/partition rather than raw image

## Home Manager (User Settings)
- TODO: 

## Details
defaults
``` json
options {
 virtman {
   enable = true,
   user = "shady",
   passthrough = true {
    vendor = "amd",
    pci_id = [ "xyz", "xyz"]
   }
 },
 user {
  name = "shady",
 },
 office2010 {
  enable = true,
 }
}
``` 
