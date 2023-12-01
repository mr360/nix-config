{ config, lib, pkgs, unstable, ... }:

{
    imports = [
        ./pkgs
    ];

    options.builderOptions.gui =
    {
        enable = lib.mkOption {
        default = false;
        example = true;
        type = lib.types.bool;
        description = ''
            Enable LQXT GUI and associated apps.
        '';
        };
    };

    config = lib.mkIf config.builderOptions.gui.enable
    {
        services.xserver = {
            # Enable the X11 windowing system.
            enable = true;

            # Enable display manager 
            displayManager.lightdm = {
                enable = true;
                background = ../wallpaper/wallpapersden.com_island-4k_2560x1080.jpg;
                greeters.gtk = with pkgs; {
                    theme.name = "Raleigh-Reloaded";
                    theme.package = localpkgs.themes.raleigh-reloaded;
                    extraConfig = ''
                        user-background=false
                    '';
                };  
            };

            # Enable LXQT desktop (excl xserver apps)
            desktopManager.lxqt.enable = true;
            excludePackages = with pkgs; [ 
                xterm
            ];
            
            # Configure keymap in X11
            layout = "us";
        };
        
        # Remove LXQT bundled apps
        environment.lxqt.excludePackages = with pkgs.lxqt; [
            lximage-qt
            screengrab
        ];

        # Enable network applet in tray
        programs.nm-applet.enable = true;

        # Install stateless global GUI applications
        environment.systemPackages = with pkgs; [
            xcompmgr
            
            localpkgs.programs.devcontainers-cli
            google-chrome
            vlc
            mtpaint
            feh
            flameshot
            qbittorrent
            popcorntime
            qalculate-qt
            simplescreenrecorder
            ferdium
            scrcpy
        ] ++ (if config.services.syncthing.enable then [ pkgs.syncthingtray ] else []) ;
        
        # Start syncthingtray as a service if syncthing is enabled 
        systemd.user.services.syncthingtray =  if config.services.syncthing.enable then 
        {
            wantedBy = [ "graphical-session.target" ];

            serviceConfig = {
                ExecStart = "${pkgs.syncthingtray}/bin/syncthingtray --connection '${config.networking.hostName}' --wait";
                Restart = "on-failure";
            };
        } else {};

        # Start ferdium as a service 
        systemd.user.services.ferdium = {
            wantedBy = [ "graphical-session.target" ];

            serviceConfig = {
                ExecStart = "${pkgs.ferdium}/bin/ferdium";
                Restart = "on-failure";
            };
        };
        
        # Start xcompmgr as a service 
        systemd.user.services.startXcompmgr = {
            wantedBy = [ "graphical-session.target" ];

            serviceConfig = {
                ExecStart = "${pkgs.xcompmgr}/bin/xcompmgr";
                Restart = "on-failure";
            };
        };
        
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
        services.pipewire = {
            enable = true;
            audio.enable = true;
            pulse.enable = true;
            alsa = {
                enable = true;
                support32Bit = true;
            };
        };
        sound.enable = true;
    };
}