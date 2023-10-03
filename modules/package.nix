({lib, pkgs, ...}: {
  # =================================================================
  # System Packages 
  # =================================================================
  # List packages installed in system profile. To search, run:
  # $ nix search wget
   environment.systemPackages = with pkgs; [
     git
     neovim 
     wget
     tmux
     tree
     gdb
     jq
     p7zip
     python3
     wineWowPackages.stable # todo: nixpkg office2010
     wine                   # todo: nixpkg office2010
     winetricks             # todo: nixpkg office2010
     hexedit
   ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
})
