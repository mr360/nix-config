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
     gcc
     bottles
     hexedit
   ];
})
