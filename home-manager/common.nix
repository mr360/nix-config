{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName = "mr360";
    userEmail = "mr360@users.noreply.github.com";
    extraConfig = {
      init.defaultBranch = "main";
      core = { 
	      editor = "nvim";
        autocrlf = "input";
      };
    };
  };
  
  programs.bash = {
    enable = true;
    enableCompletion = true;
    bashrcExtra = ''
    '';

    shellAliases = {
    };
  };

  home.stateVersion = "23.05";
  programs.home-manager.enable = true;
}