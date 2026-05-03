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
      foot
    ];

    users.users.${config.builderOptions.user.name}.extraGroups = [
      "video"
      "render"
    ];

    # Allow software rendering on headless servers with no GPU
    environment.variables.WLR_RENDERER_ALLOW_SOFTWARE = "1";
  };
}
