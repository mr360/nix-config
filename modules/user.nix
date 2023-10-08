
{config, lib, pkgs, ...}: 

{
   users.users.shady = {
    isNormalUser = true;
     extraGroups = [ "wheel" ];
     initialPassword = "1234";
   };

  users.mutableUsers = false;
}
