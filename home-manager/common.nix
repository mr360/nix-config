{
  config,
  pkgs,
  networking,
  flakePath,
  serverUrl,
  ...
}:

{
  programs.git = {
    enable = true;
    settings = {
      user.name = "mr360";
      user.email = "mr360@users.noreply.github.com";
      extraConfig = {
        init.defaultBranch = "main";
        core = {
          editor = "nvim";
          autocrlf = "input";
        };
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
      devcontainer_init = "cp -rf ${flakePath}/dotfile/.template/. .";
      devcontainer_start = "devcontainer up --workspace-folder .  --remove-existing-container";
      devcontainer_tunnel = "devcontainer exec --workspace-folder . code tunnel --accept-server-license-terms --name ${networking.hostName}";
      devcontainer_vim = "devcontainer exec --workspace-folder . nvim .";
      devcontainer_bash = "devcontainer exec --workspace-folder . bash";

      wyp = "waypipe ssh foxskis@${serverUrl} --";

      gd = "tmux popup -d \"$(pwd)\" -h 95% -w 99% -y 55% -E \"nix run github:agavra/tuicr -- --theme dark\"";
    };
  };

  programs.readline = {
    enable = true;
    bindings = { };
    extraConfig = ''
      set editing-mode vi
      set keymap vi-command
    '';
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    GIT_EDITOR = "nvim";
  };

  home.file = {
    ".tmux.conf" = {
      text = (builtins.readFile ../dotfile/.config/.tmux.conf);
    };
  };

  xdg.configFile."nvim/init.lua" = {
    source = config.lib.file.mkOutOfStoreSymlink ../dotfile/.config/nvim/init.lua;
  };

  home.stateVersion = "25.11";
  programs.home-manager.enable = true;
}
