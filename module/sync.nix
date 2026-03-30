{ config, lib, pkgs, ... }: 

let
  userName = config.builderOptions.user.name;
in
{
  options.builderOptions.sync=
  {
      enable = lib.mkOption {
      default = false;
      example = true;
      type = lib.types.bool;
      description = ''
          Enable syncing folders with BtSync 
      '';
      };
  };

  config = lib.mkIf (config.builderOptions.sync.enable)
  {
  	services.resilio = {
	   enable = true;
	   checkForUpdates = false;
	};
	users.users.${userName}.extraGroups = lib.mkAfter [ "rslsync" ]; 	
  };
}
