{ config, pkgs, ... }:

# LXQT config settings
#  = Window Snapping shortcuts 
#  = General shortcuts 
# Git config
# Vscode config
# QTerminal?? bash?
# Neovim config

{
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

  home.username = "shady";
  home.homeDirectory = "/home/shady";
  home.packages = with pkgs; [
    nnn
  ];



  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.05";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
