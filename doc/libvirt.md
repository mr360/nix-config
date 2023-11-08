## Misc

chown -R shady:users /home/shady/.local/share/img/
nix-shell -p pciutils

## Gaming VFIO

- virsh connect qemu://session
- virsh define win10-1080ti.virt.xml
- virsh start win10-1080ti

## QEMU Network commands

- virsh net-define default.virt.xml
- virsh net-start default
- virsh net-autostart default
- virsh net-destroy default
- virsh net-undefine default

## Notes

- Remember to change the user account on ln29 & ln80 of `win10-1080ti.virt.xml`
- To resolve the following permission issue -- execute `sudo chown shady /dev/vfio/17` as root user.

```bash
[shady@amd-desktop:~]$ virsh start win10-1080ti
error: Failed to start domain 'win10-1080ti'
error: internal error: qemu unexpectedly closed the monitor: 2023-10-09T19:17:18.649795Z qemu-system-x86_64: -device {"driver":"vfio-pci","host":"0000:0c:00.0","id":"hostdev0","bus":"pci.15","addr":"0x0"}: vfio 0000:0c:00.0: failed to open /dev/vfio/17: Permission denied
```

- To resolve permission issues with keyboard and mice -- execute

```bash
  sudo chown shady:users /dev/input/by-id/usb-Corsair_Corsair_K70R_Gaming_Keyboard-if02-event-kbd
  sudo chown shady:users /dev/input/by-id/usb-Logitech_USB_Receiver-if01-event-mouse
```
