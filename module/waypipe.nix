{ config, lib, pkgs, ... }:

let
  #resolution = config.builderOptions.waypipe.resolution;
in
{
  options.builderOptions.waypipe = {
    enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Install waypipe and cage for remote Wayland app forwarding over SSH.";
    };
    # resolution = lib.mkOption {
    #   default = "1600x900@30";
    #   type = lib.types.str;
    #   description = "Default output resolution for cage sessions (wlr-randr custom-mode format).";
    # };
  };

  config = lib.mkIf config.builderOptions.waypipe.enable {
    environment.systemPackages = with pkgs; [
      waypipe
      cage
      #wlr-randr
      kicad
    ];

    users.users.${config.builderOptions.user.name}.extraGroups = [
      "video"
      "render"
    ];

    #boot.kernelModules = [ "vkms" ];
    #boot.kernelParams = [ "video=Virtual-1:${resolution}" ];

    #services.udev.extraRules = ''
    #  SUBSYSTEM=="drm", KERNEL=="card*", KERNELS=="vkms", SYMLINK+="dri/vkms"
    #'';

    # Force pixman software renderer — headless server has no GPU for GBM/DMABUF
    environment.variables.WLR_RENDERER = "pixman";
    #environment.variables.WLR_DRM_DEVICES = "/dev/dri/vkms";
  };
}
