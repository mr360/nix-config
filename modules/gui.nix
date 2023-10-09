{ config, lib, pkgs, ... }:

{
    options.custom.gui =
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

    config = lib.mkIf config.custom.gui.enable
    {
        # Enable the X11 windowing system.
        services.xserver.enable = true;

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
        services.xserver.xkbOptions = "eurosign:e,caps:escape";

        # Install GUI applications
        environment.systemPackages = with pkgs; [
            bottles
        vscode
        google-chrome
        vlc
        ];

        # Enable sound and printing
        services.printing.enable = true;
        hardware.pulseaudio.enable = true;
        sound.enable = true;
    };
}