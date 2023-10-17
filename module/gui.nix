{ config, lib, pkgs, ... }:

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
        # Enable the X11 windowing system.
        services.xserver.enable = true;

        # Enable display manager 
        services.xserver.displayManager.lightdm = {
            enable = true;
            background = "#234365";
            greeters.gtk = with pkgs; {
                theme.name = "Raleigh-Reloaded";
                theme.package = localpkgs.themes.raleigh-reloaded;
                extraConfig = ''
                    user-background=false
                '';
            };  
        };

        # Enable LXQT desktop (excl apps)
        services.xserver.desktopManager.lxqt.enable = true;
        services.xserver.excludePackages = [ 
            pkgs.xterm
        ];
        environment.lxqt.excludePackages = [
            pkgs.lxqt.lximage-qt
            pkgs.lxqt.screengrab
        ];

        # Configure keymap in X11
        services.xserver.layout = "us";

        # Install stateless global GUI applications
        environment.systemPackages = with pkgs; [
            google-chrome
            vlc

            mtpaint
            feh
            flameshot

            qbittorrent
            popcorntime

            qalculate-qt
        ];

        # Start systemd services for GUI packages
        systemd.user.services.flameshot = {
            wantedBy = [ "graphical-session.target" ];
            partOf = [ "graphical-session.target" ];

            serviceConfig = {
                ExecStart = "${pkgs.flameshot}/bin/flameshot";
                Restart = "on-abort";

                LockPersonality = true;
                MemoryDenyWriteExecute = true;
                NoNewPrivileges = true;
                PrivateUsers = true;
                RestrictNamespaces = true;
                SystemCallArchitectures = "native";
                SystemCallFilter = "@system-service";
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