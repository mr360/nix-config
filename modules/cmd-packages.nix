{ config, lib, pkgs, ... }: 

{
  options.custom.cmdpkgs =
  {
      enable = lib.mkOption {
      default = false;
      example = true;
      type = lib.types.bool;
      description = ''
          Enable CMD packages.
      '';
      };
  };

  config = lib.mkIf config.custom.cmdpkgs.enable
  {
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
      hexedit
    ];
  };
}