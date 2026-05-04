{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./pkgs
    ./cmt.nix
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
    builderOptions.cmt.docker.enable = true;

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
