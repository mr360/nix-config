
{config, lib, pkgs, ...}: 

{
  options.builderOptions.user =
  {
    name = lib.mkOption {
      default = "shady";
      example = "shady";
      type = lib.types.str;
      description = ''
        Name of user to be created.
      '';
    };
  };

  config.users = {
    mutableUsers = false;
    users.${config.builderOptions.user.name} = {
      isNormalUser = true;
      extraGroups = [ 
        "wheel"
        "networkmanager" 
        ];
        
      initialPassword = "1234";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIICtnasp85/WNYFdKEmV+izIAt12oKntK7eEFhwo5fhk qd0097@gmail.com"
      ];
    };
  };
}

