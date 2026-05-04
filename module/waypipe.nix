{ config, lib, pkgs, ... }:

let
in
{
  options.builderOptions.waypipe = {
    enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Install waypipe and cage for remote Wayland app forwarding over SSH.";
    };
  };

  config = lib.mkIf config.builderOptions.waypipe.enable {
    environment.systemPackages = with pkgs; [
      waypipe
      cage
      
      kicad
      freecad
    ];

    users.users.${config.builderOptions.user.name}.extraGroups = [
      "video"
      "render"
    ];

    environment.variables.WLR_RENDERER = "pixman";
  };
}
