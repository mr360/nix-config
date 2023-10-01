({lib, pkgs, ...}: {
  # =================================================================
  # Misc Options
  # =================================================================
  nixpkgs.config.allowUnfree = true;
  hardware.opengl.enable = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
})
