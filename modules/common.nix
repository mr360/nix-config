({...}: {
  nixpkgs.config.allowUnfree = true;
  hardware.opengl.enable = true;
})
