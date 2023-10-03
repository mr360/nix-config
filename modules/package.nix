({pkgs, ...}: {
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
})
