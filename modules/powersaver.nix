{config, lib, pkgs, ...}: 

{
  options.builderOptions.powersaver =
  {
      enable = lib.mkOption {
      default = false;
      example = true;
      type = lib.types.bool;
      description = ''
          Enable powersaving features.
      '';
      };
  };

  config = lib.mkIf config.builderOptions.powersaver.enable
  {
  };
}