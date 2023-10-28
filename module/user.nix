
{config, lib, pkgs, ...}: 

let 
  isoPrefix = if builtins.hasAttr "config.isoImage" config then "/iso" else "";
in
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
        
      passwordFile = "${isoPrefix}/etc/nixos/dotfile/.cred/user/${config.builderOptions.user.name}/hashed.passwd";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIICtnasp85/WNYFdKEmV+izIAt12oKntK7eEFhwo5fhk qd0097@gmail.com"
      ];
    };
  };
}

