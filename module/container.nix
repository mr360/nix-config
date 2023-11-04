{ config, lib, pkgs, ... }: 

# Manual update of docker versions every 12 months
# Next update scheduled for 1st Dec 2024
let
  uid = toString config.users.users.${config.builderOptions.user.name}.uid;
  gid = toString config.users.groups.users.gid;
  timezone = "Australia/Sydney";
in
{
  options.builderOptions.docker =
  {
      enable = lib.mkOption {
      default = false;
      example = true;
      type = lib.types.bool;
      description = ''
          Enable docker virtualisation
      '';
      };

      idrac6 = lib.mkOption {
      default = false;
      example = true;
      type = lib.types.bool;
      description = ''
          Enable IDRAC6 docker image for r710
      '';
      };

      nginx = lib.mkOption {
      default = false;
      example = true;
      type = lib.types.bool;
      description = ''
          Enable NGINX docker image
      '';
      };

      jellyfin = lib.mkOption {
      default = false;
      example = true;
      type = lib.types.bool;
      description = ''
          Enable jellyfin docker image
      '';
      };

      code = lib.mkOption {
      default = false;
      example = true;
      type = lib.types.bool;
      description = ''
          Enable vscode server docker image
      '';
      };    

      nextcloud = lib.mkOption {
      default = false;
      example = true;
      type = lib.types.bool;
      description = ''
          Enable nextcloud docker image
      '';
      };   

      tailscale = lib.mkOption {
      default = false;
      example = true;
      type = lib.types.bool;
      description = ''
          Enable tailscale vpn docker image
      '';
      };         
  };

  config = lib.mkMerge [
  (lib.mkIf (config.builderOptions.docker.enable) 
  {
    virtualisation.docker.rootless = {
      enable = true;
      setSocketVariable = true;
    };
  })

  (lib.mkIf (config.builderOptions.docker.idrac6)
  {
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
            # After installation need to run: chown -R shady:users /tmp/shady
            volumes = [
              "/tmp/${config.builderOptions.user.name}/idrac/app:/app"
              "/tmp/${config.builderOptions.user.name}/idrac/media:/vmedia"
              "/tmp/${config.builderOptions.user.name}/idrac/screenshots:/screenshots"
            ];
        };
      };
    };
  })
  
  (lib.mkIf (config.builderOptions.docker.nginx) 
  {
    virtualisation.oci-containers = { 
      backend = "docker";
      containers = {
        nginx = {
            autoStart = true;
            image = "nginx:1.25.2-alpine-slim";
            ports = [ 
              "8094:8094"
              "8095:8443"
              "8096:9443"
              ];
            environment = {
              NGINX_PORT="80";
            };
            volumes = [
            ];
        };
      };
    };
  })

  (lib.mkIf (config.builderOptions.docker.jellyfin) 
  {
    networking.firewall.allowedTCPPorts = [ 8096 ];
    virtualisation.oci-containers = { 
      backend = "docker";
      containers = {
        jellyfin = {
            autoStart = true;
            image = "linuxserver/jellyfin:10.8.11";
            ports = [ 
              "8096:8096"
              ];
            environment = {
              PUID= uid;
              PGID= gid;
              TZ=timezone;
            };
            volumes = [
              "/mnt/storage/jellyfin/library:/config"
              "/mnt/storage/jellyfin/data:/data"
              "/mnt/storage/jellyfin/cache:/cache"
              #/mnt/storage/drive/LtsData/Media:/media/lts1
            ];
        };
      };
    };
  })

  (lib.mkIf (config.builderOptions.docker.code) 
  {
    networking.firewall.allowedTCPPorts = [ 8443 ];
    virtualisation.oci-containers = { 
      backend = "docker";
      containers = {
        code = {
            autoStart = true;
            image = "linuxserver/code-server:4.18.0";
            ports = [ 
              "8443:8443"
              ];
            environment = {
              PUID=uid;
              PGID=gid;
              TZ=timezone;
              DEFAULT_WORKSPACE="/mnt/storage/drive/Documents/development";
            };
            volumes = [
              "/mnt/storage/drive:/mnt/storage/drive"
              #"~/nixos/dotfile/.config/code:/config"
            ];
        };
      };
    };
  })

  (lib.mkIf (config.builderOptions.docker.nextcloud) 
  {
    networking.firewall.allowedTCPPorts = [ 9443 ];
    virtualisation.oci-containers = { 
      backend = "docker";
      containers = {
        nextcloud = {
            autoStart = true;
            image = "linuxserver/nextcloud:27.1.3";
            ports = [ 
              "9443:443"
              ];
            environment = {
              PUID=uid;
              PGID=gid;
              TZ=timezone;            
            };
            volumes = [
              "/mnt/storage/nextcloud/config:/config"
              "/mnt/storage/nextcloud/data:/data"
            ];
        };
      };
    };
  })

  (lib.mkIf (config.builderOptions.docker.tailscale) 
  {
    virtualisation.oci-containers = { 
      backend = "docker";
      containers = {
        tailscale = {
            autoStart = true;
            image = "tailscale/tailscale:v1.52.0";
            ports = [ 
              ];
            environment = {
            };
            volumes = [
            ];
        };
      };
    };
  })
];
}