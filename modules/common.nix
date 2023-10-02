({lib, pkgs, ...}: {
  # =================================================================
  # Misc Options
  # =================================================================
  nixpkgs.config.allowUnfree = true;
  hardware.opengl.enable = true;
})
