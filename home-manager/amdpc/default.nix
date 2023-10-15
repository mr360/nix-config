{ config, pkgs, ... }:

{
  /*
    Note: Limited usage of home-manager. Only used for linking xdg config files rather than using nix styled option layout. 
    Once home-manager becomes officially integrated with nix then we can think about it :-) 
  */

  home.username = "shady";
  home.homeDirectory = "/home/shady";
  home.packages = with pkgs; [
    vscode
    neovim
  ];

  xdg = {
    enable = true;

    # Openbox and LXQT desktop settings
    configFile."lxqt" = {
      source = config.lib.file.mkOutOfStoreSymlink ../../dotfile/.config/lxqt;
      recursive = true;
    };
    configFile."openbox" = {
      source = config.lib.file.mkOutOfStoreSymlink ../../dotfile/.config/openbox;
      recursive = true;
    };
    
    # LXQT Custom theme files
    dataFile."fonts" = {
      source = config.lib.file.mkOutOfStoreSymlink ../../dotfile/.local/share/fonts;
      recursive = true;
    };
    dataFile."lxqt" = {
      source = config.lib.file.mkOutOfStoreSymlink ../../dotfile/.local/share/lxqt;
      recursive = true;
    };
    dataFile."themes" = {
      source = config.lib.file.mkOutOfStoreSymlink ../../dotfile/.local/share/themes;
      recursive = true;
    };

    # QTerm settings
    configFile."qterminal.org" = {
      source = config.lib.file.mkOutOfStoreSymlink ../../dotfile/.config/qterminal.org;
      recursive = true;
    };

    # PCManFM 
    configFile."pcmanfm-qt" = {
      source = config.lib.file.mkOutOfStoreSymlink ../../dotfile/.config/pcmanfm-qt;
      recursive = true;
    };

    # Feh  Image Viewer 
    configFile."feh" = {
      source = config.lib.file.mkOutOfStoreSymlink ../../dotfile/.config/feh;
      recursive = true;
    };
  };
  
  # Git & Bash
  programs.git = {
    enable = true;
    userName = "mr360";
    userEmail = "qd0097@gmail.com";
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
      ginit = ''eval "$(ssh-agent -s)" && ssh-add ~/.ssh/id_ed25519_git'';
    };
  };

  # TODO GUI Quickview Shortcuts + File Assoications

  home.stateVersion = "23.05";
  programs.home-manager.enable = true;
}
