{
  config,
  pkgs,
  networking,
  flakePath,
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
      devcontainer_nvim = "devcontainer exec --workspace-folder . nvim .";
      devcontainer_bash = "devcontainer exec --workspace-folder . bash";
      devcontainer_tunnel = "devcontainer exec --workspace-folder . code tunnel --accept-server-license-terms --name ${networking.hostName}";
    };
  };

programs.readline = {
  enable = true;

  bindings = {};

  extraConfig = ''
    set editing-mode vi
    set keymap vi-command
  '';
};

  home.file = {
    ".tmux.conf" = {
      text = (builtins.readFile ../dotfile/.config/.tmux.conf);
    };
  };

  # configFile."nvim" = {
  #   source = config.lib.file.mkOutOfStoreSymlink ../../dotfile/.config/nvim;
  #   recursive = true;
  # };

  home.stateVersion = "25.11";
  programs.home-manager.enable = true;
}
