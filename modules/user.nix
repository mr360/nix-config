
({lib, pkgs, ...}: {
  # =================================================================
  # Main User Setup
  # param:
  # 	string: user
  # =================================================================
   users.users.shady = {
    isNormalUser = true;
     extraGroups = [ "wheel" ];
     packages = with pkgs; [
       google-chrome
       vscode
     ];
     initialPassword = "1234";
   };

  users.mutableUsers = false;
})
