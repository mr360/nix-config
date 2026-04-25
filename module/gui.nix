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
    services= {
      displayManager.lightdm.enable = true;
      desktopManager.pantheon.enable = true;
      # excludePackages = with pkgs; [
      # ];
      xkb.layout = "us";
    };

    # # Remove DE bundled apps
    # environment.pantheon.excludePackages = with pkgs.lxqt; [
    # ];

    # Install stateless global GUI applications
    environment.systemPackages =
      with pkgs;
      [
        wl-clipboard  
        firefox
        vlc
        feh
        flameshot
        popcorntime
        qalculate-qt
      ];

    # Enable network applet in tray
    programs.nm-applet.enable = true;

    # Start systemd services for GUI packages
    systemd.user.services.flameshot = {
      wantedBy = [ "graphical-session.target" ];

      serviceConfig = {
        ExecStart = "${pkgs.flameshot}/bin/flameshot";
        Restart = "on-abort";
      };
    };

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
