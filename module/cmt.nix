{
  config,
  lib,
  ...
}:
let
  user = config.builderOptions.user.name;
in
{
  options.builderOptions.cmt = {
    docker = lib.mkOption {
      default = { };
      type = lib.types.submodule {
        options.enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Enable Docker daemon";
        };
      };
    };
    podman = lib.mkOption {
      default = { };
      type = lib.types.submodule {
        options.enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Enable Podman daemon";
        };
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf config.builderOptions.cmt.docker.enable {
      virtualisation.docker = {
        enable = true;
        enableOnBoot = true;
      };
      users.extraGroups.docker.members = [ user ];
    })
    (lib.mkIf config.builderOptions.cmt.podman.enable {
      virtualisation.podman = {
        enable = true;
        dockerCompat = true;
        dockerSocket.enable = true;
        defaultNetwork.settings.dns_enabled = true;
        autoPrune = {
          enable = true;
          dates = "weekly";
          flags = [ "--all" ];
        };
      };
    })
  ];
}
