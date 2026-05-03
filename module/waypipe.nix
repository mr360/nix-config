{ config, lib, pkgs, ... }:

{
  options.builderOptions.waypipe.enable = lib.mkOption {
    default = false;
    type = lib.types.bool;
    description = "Install waypipe and cage for remote Wayland app forwarding over SSH.";
  };

  config = lib.mkIf config.builderOptions.waypipe.enable {
    environment.systemPackages = with pkgs; [
      waypipe
      cage
    ];
  };
}
