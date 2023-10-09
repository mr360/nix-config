{config, lib, pkgs, ...}: 

{
  options.custom.powersaver =
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

  config = lib.mkIf config.custom.powersaver.enable
  {
  };
}