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
    virtualisation.docker.rootless = {
      enable = true;
      setSocketVariable = true;
    };

    # TODO: Fix permissions issue where these files are not created as shady users
    /*systemd.tmpfiles.rules = [
        "d /home/${config.builderOptions.user.name}/idrac/app 0777 ${config.builderOptions.user.name} users -"
        "d /home/${config.builderOptions.user.name}/idrac/media 0777 ${config.builderOptions.user.name} users -"
        "d /home/${config.builderOptions.user.name}/idrac/screenshots 0777 ${config.builderOptions.user.name} users -"
    ];*/

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
              #VIRTUAL_ISO="name_of_iso.iso";
            };
            volumes = [
              "/home/${config.builderOptions.user.name}/idrac/app:/app"
              "/home/${config.builderOptions.user.name}/idrac/media:/vmedia"
              "/home/${config.builderOptions.user.name}/idrac/screenshots:/screenshots"
            ];
        };
      };
    };
  };
}