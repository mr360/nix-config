{ config, lib, pkgs, ... }: 

{
  options.builderOptions.cmdpkgs =
  {
      enable = lib.mkOption {
      default = false;
      example = true;
      type = lib.types.bool;
      description = ''
          Enable global stateless CMD packages.
      '';
      };
  };

  config = lib.mkIf config.builderOptions.cmdpkgs.enable
  {
    environment.systemPackages = with pkgs; [
      git
      wget
      tree
      gdb
      jq
      p7zip
      python3
      gcc
      hexedit
      nnn
      tmux
      pcalc
    ];
  };
}