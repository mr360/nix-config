{ config, pkgs, ... }:

{
  /*
    Note: Limited usage of home-manager. Only used for linking xdg config files rather than using nix styled option layout. 
    Once home-manager becomes mature then we can think about it :-) 
  */

  imports = [
    ../common.nix
  ];

  home.packages = with pkgs; [
    vscode
  ];

  # TODO: Issue: Needs to be run twice -- first time to create the panel.conf & another to symlink
  # Note: Do not edit panel.conf rather edit the panel.conf.base file instead
  home.file = {
    "panel.conf" = {
      target = "/nixos/dotfile/.config/lxqt/panel.conf";
      text = (builtins.readFile ../../dotfile/.config/lxqt/panel.conf.base) + ''
        [quicklaunch]
        alignment=Left
        apps\1\desktop=${pkgs.pcmanfm-qt}/share/applications/pcmanfm-qt.desktop
        apps\2\desktop=${pkgs.google-chrome}/share/applications/google-chrome.desktop
        apps\3\desktop=${pkgs.lxqt.qterminal}/share/applications/qterminal.desktop
        apps\4\desktop=${pkgs.vscode}/share/applications/code.desktop
        apps\size=4
        type=quicklaunch
      '';
    };
  };

  xdg = {
    enable = true;

    # Openbox and LXQT desktop settings
    configFile."lxqt" = {
      source = config.lib.file.mkOutOfStoreSymlink ../../dotfile/.config/lxqt;
      recursive = true;
    };
    configFile."openbox" = {
      source = config.lib.file.mkOutOfStoreSymlink ../../dotfile/.config/openbox;
      recursive = true;
    };
    configFile."gtk-3.0" = {
      source = config.lib.file.mkOutOfStoreSymlink ../../dotfile/.config/gtk-3.0;
      recursive = true;
    };

    # LXQT Custom theme files
    dataFile."fonts" = {
      source = config.lib.file.mkOutOfStoreSymlink ../../dotfile/.local/share/fonts;
      recursive = true;
    };
    dataFile."lxqt" = {
      source = config.lib.file.mkOutOfStoreSymlink ../../dotfile/.local/share/lxqt;
      recursive = true;
    };
    dataFile."themes" = {
      source = config.lib.file.mkOutOfStoreSymlink ../../dotfile/.local/share/themes;
      recursive = true;
    };

    # QTerm settings
    configFile."qterminal.org" = {
      source = config.lib.file.mkOutOfStoreSymlink ../../dotfile/.config/qterminal.org;
      recursive = true;
    };

    # PCManFM 
    configFile."pcmanfm-qt" = {
      source = config.lib.file.mkOutOfStoreSymlink ../../dotfile/.config/pcmanfm-qt;
      recursive = true;
    };

    # Feh  Image Viewer 
    configFile."feh" = {
      source = config.lib.file.mkOutOfStoreSymlink ../../dotfile/.config/feh;
      recursive = true;
    };

    # VLC settings 
    configFile."vlc/vlcrc" = {
      source = config.lib.file.mkOutOfStoreSymlink ../../dotfile/.config/vlc/vlcrc;
      recursive = false;
    };

    # Syncthing System Tray
    configFile."syncthingtray.ini" = {
      source = config.lib.file.mkOutOfStoreSymlink ../../dotfile/.config/syncthingtray.ini;
      recursive = false;
    };
  };

  home.file = {
    ".config/mimeapps.list" = {
      text = (builtins.readFile ../../dotfile/.config/mimeapps.list.base) + '''';
    };
  };

  programs.bash.shellAliases = {
    enterssh = ''ssh foxskis@remote.storage-r710.home'';
    startvm = ''
      sudo chown ${config.home.username} /dev/vfio/17 && 
      sudo chown ${config.home.username}:users /dev/input/by-id/usb-*-event-kbd &&
      sudo chown ${config.home.username}:users /dev/input/by-id/usb-*-event-mouse &&
      virsh -c qemu:///session start win10-1080ti ; 
      looking-glass-client win:size=1680x1050'';
  };

}
