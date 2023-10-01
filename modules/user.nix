
({lib, pkgs, ...}: {
  # =================================================================
  # Main User Setup
  # =================================================================
   users.users.shady = {
    isNormalUser = true;
     extraGroups = [ "wheel" "libvirtd" ];
     packages = with pkgs; [
       firefox
       google-chrome
       vscode
     ];
     initialPassword = "1234";
   };

  users.mutableUsers = false;
})
