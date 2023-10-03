({lib, ...}: {
  nixpkgs.config.allowUnfree = true;
  hardware.opengl.enable = true;

  time.timeZone = "Australia/Sydney";

  services.printing.enable = true;

  sound.enable = true;
  hardware.pulseaudio.enable = true;
})
