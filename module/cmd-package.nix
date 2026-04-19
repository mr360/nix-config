{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./pkgs
  ];

  options.builderOptions.cmdpkgs = {
    enable = lib.mkOption {
      default = false;
      example = true;
      type = lib.types.bool;
      description = ''
        Enable global stateless CMD packages.
      '';
    };
  };

  config = lib.mkIf config.builderOptions.cmdpkgs.enable {
    environment.systemPackages = with pkgs; [
      git
      tree
      jq
      p7zip
      hexedit
      tmux
      pcalc
      unstable.neovim
      unrar
      localpkgs.devcontainer-cli
    ];
  };
}
