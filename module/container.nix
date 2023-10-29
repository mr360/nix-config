{ config, lib, pkgs, ... }: 

{
  options.builderOptions.docker =
  {
      idrac6 = lib.mkOption {
      default = false;
      example = true;
      type = lib.types.bool;
      description = ''
          Enable IDRAC6 docker image for r710
      '';
      };
  };

  config = lib.mkIf config.builderOptions.docker.idrac6
  {
    # TODO: Move this to a options.builderOptions.docker.enable toggle
    # once I have another docker service which needs to be run.
    virtualisation.docker.rootless = {
      enable = true;
      setSocketVariable = true;
    };

    virtualisation.oci-containers = { 
      backend = "docker";
      containers = {
        idrac6 = {
            autoStart = true;
            image = "domistyle/idrac6:v0.9";
            ports = [ 
              "5800:5800"
              "5900:5900"
              ];
            environment = {
              IDRAC_HOST = "192.168.1.130";
              IDRAC_USER = "root";
              IDRAC_PASSWORD = "root";
            };
            volumes = [
              "/tmp/${config.builderOptions.user.name}/idrac/app:/app"
              "/tmp/${config.builderOptions.user.name}/idrac/media:/vmedia"
              "/tmp/${config.builderOptions.user.name}/idrac/screenshots:/screenshots"
            ];
        };
      };
    };
  };
}