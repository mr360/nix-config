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
      devenv-init = ''nix flake init --template github:cachix/devenv'';
    };
  };

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };
  
  home.file = {
    ".config/direnv/config.toml" = {
      text = ''
        [whitelist]
        prefix = [ 
          "/home/${config.home.username}/sync/development", 
          "/home/${config.home.username}/nixos"
          ]
      '';
    };
  };

  home.file = {
    ".tmux.conf" = {
      text = (builtins.readFile ../dotfile/.config/.tmux.conf);
    };
  };

  home.stateVersion = "23.05";
  programs.home-manager.enable = true;
}