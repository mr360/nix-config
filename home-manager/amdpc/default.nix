{ config, pkgs, ... }:

{
  home.username = "shady";
  home.homeDirectory = "/home/shady";
  home.packages = with pkgs; [
    git
    vscode
    neovim
    tmux
    nnn
  ];

  xdg = {
    enable = true;

    # Openbox and LXQT desktop settings
    configFile."lxqt" = {
      source = config.lib.file.mkOutOfStoreSymlink ../../dotfiles/.config/lxqt;
      recursive = true;
    };
    configFile."openbox" = {
      source = config.lib.file.mkOutOfStoreSymlink ../../dotfiles/.config/openbox;
      recursive = true;
    };
    
    # LXQT Custom theme files
    dataFile."fonts" = {
      source = config.lib.file.mkOutOfStoreSymlink ../../dotfiles/.local/share/fonts;
      recursive = true;
    };
    dataFile."icons" = {
      source = config.lib.file.mkOutOfStoreSymlink ../../dotfiles/.local/share/icons;
      recursive = true;
    };
    dataFile."lxqt" = {
      source = config.lib.file.mkOutOfStoreSymlink ../../dotfiles/.local/share/lxqt;
      recursive = true;
    };
    dataFile."themes" = {
      source = config.lib.file.mkOutOfStoreSymlink ../../dotfiles/.local/share/themes;
      recursive = true;
    };

    # QTerm settings
    configFile."qterminal.org" = {
      source = config.lib.file.mkOutOfStoreSymlink ../../dotfiles/.config/qterminal.org;
      recursive = true;
    };

    # PCManFM 
    configFile."pcmanfm-qt" = {
      source = config.lib.file.mkOutOfStoreSymlink ../../dotfiles/.config/pcmanfm-qt;
      recursive = true;
    };
  };
  
  # Git & Bash
  programs.git = {
    enable = true;
    userName = "mr360";
    userEmail = "qd0097@gmail.com";
  };
  programs.bash = {
    enable = true;
    enableCompletion = true;
    bashrcExtra = ''
    '';

    shellAliases = {
      ginit = ''eval "$(ssh-agent -s)" && ssh-add ~/.ssh/id_ed25519_git'';
      xrf = "xrandr --output HDMI-1 --off && xrandr --auto  && xrandr --output HDMI-1 --primary  --output DP-1  --right-of HDMI-1";
    };
  };

  # TODO Shortcut overlay + injection

  # Editors
  # TODO vscode

  # TODO neovim
  
  # TODO tmux

  home.stateVersion = "23.05";
  programs.home-manager.enable = true;
}
