## Linux Commands 
fc-cache -f -v                  // Rebuild font cache after font addition
openbox --reconfigure           // Restart after changes 
find . -type f -name "win10*"   // Find command recursive

https://unix.stackexchange.com/questions/225401/how-to-see-full-log-from-systemctl-status-service
journalctl -u service-name              // View service logs
journalctl -u service-name.service -b   // View service logs from current boot
