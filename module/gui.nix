{
  config,
  lib,
  pkgs,
  unstable,
  ...
}:

{
  imports = [
    ./pkgs
  ];

  options.builderOptions.gui = {
    enable = lib.mkOption {
      default = false;
      example = true;
      type = lib.types.bool;
      description = ''
        Enable GUI and associated apps.
      '';
    };
  };

  config = lib.mkIf config.builderOptions.gui.enable {
    services = {
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
      gnome.core-apps.enable = false;
    };

    # Install stateless global GUI applications
    environment.systemPackages =
      with pkgs;
      [
        wl-clipboard  
        firefox
        vlc
        popcorntime
        qalculate-qt
        localsend

        alacritty
        nautilus
      ];

    services.gnome.gcr-ssh-agent.enable = false;

    # Enable network applet in tray
    programs.nm-applet.enable = true;

    # Enable sound and printing
    services.printing.enable = true;
    services.printing.drivers = with pkgs; [
      localpkgs.drivers.cups-brother-mfcl2800dw
    ];
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
    services.pipewire = {
      enable = true;
      audio.enable = true;
      pulse.enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
    };
  };
}
