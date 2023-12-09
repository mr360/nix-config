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
      if command -v tmux &> /dev/null && [ -n "$PS1" ] && \
      [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] \
      && [ -z "$TMUX" ]; then
        exec tmux
      fi
    '';

    shellAliases = {
      devcontainer_init = ''cp -rf ~/nixos/dotfile/.template/. .'';
      devcontainer_nvim = ''devcontainer exec --workspace-folder . nvim .'';
    };
  };

  home.file = {
    ".tmux.conf" = {
      text = (builtins.readFile ../dotfile/.config/.tmux.conf);
    };
  };

  home.stateVersion = "23.11";
  programs.home-manager.enable = true;
}