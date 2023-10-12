{ config, pkgs, ... }:

{
  home.username = "shady";
  home.homeDirectory = "/home/shady";
  home.packages = with pkgs; [
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
    };
  };


  # Editors
  # TODO vscode & neovim

  # TODO Shortcuts / Icons / Menues ect

  home.stateVersion = "23.05";
  programs.home-manager.enable = true;
}
