{ config, lib, pkgs, ... }: 

# Manual update of docker versions every 12 months
# Next update scheduled for 1st Dec 2024
let
  uid = toString config.users.users.${config.builderOptions.user.name}.uid;
  gid = toString config.users.groups.users.gid;
  user = "${config.builderOptions.user.name}";
  timezone = "Australia/Sydney";
  dockerStoragePath = "/mnt/storage/docker";
  documentDrivePath = "/mnt/storage/drive";
in
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
  (lib.mkIf (config.builderOptions.docker.idrac6)
  {
    virtualisation = {
      docker = { enable = true; enableOnBoot = true; };
      oci-containers = { 
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
              # After installation need to run: chown -R shady:users /{dockerStoragePath}/idrac
              volumes = [
                "${dockerStoragePath}/idrac/app:/app"
                "${dockerStoragePath}/idrac/media:/vmedia"
                "${dockerStoragePath}/idrac/screenshots:/screenshots"
              ];
          };
        };
      };
    };
  })

  (lib.mkIf (config.builderOptions.docker.jellyfin) 
  {
    networking.firewall.allowedTCPPorts = [ 9001 ];
    virtualisation = {
      docker = { enable = true; enableOnBoot = true; };
      oci-containers = { 
        backend = "docker";
        containers = {
          jellyfin = {
              autoStart = true;
              image = "linuxserver/jellyfin:10.8.11";
              ports = [ 
                "9001:8096"
              ];
              environment = {
                PUID= uid;
                PGID= gid;
                TZ=timezone;
                JELLYFIN_LOG_DIR = "/log";
                JELLYFIN_DATA_DIR = "/data";
                JELLYFIN_CONFIG_DIR = "/config";
                JELLYFIN_CACHE_DIR = "/cache";
              };
              volumes = [
                "${dockerStoragePath}/jellyfin/config:/config"
                "${dockerStoragePath}/jellyfin/data:/data"
                "${dockerStoragePath}/jellyfin/cache:/cache"
                "${dockerStoragePath}/jellyfin/log:/log"
                #${documentDrivePath}/LtsData/Media:/media/library
              ];
          };
        };
      };
    };
  })

  (lib.mkIf (config.builderOptions.docker.code) 
  {
    networking.firewall.allowedTCPPorts = [ 9002 ];
    virtualisation = {
      docker = { enable = true; enableOnBoot = true; };
      oci-containers = {  
        backend = "docker";
        containers = {
          code = {
              autoStart = true;
              image = "linuxserver/code-server:4.18.0";
              ports = [ 
                "9002:8443"
                ];
              environment = {
                PUID=uid;
                PGID=gid;
                TZ=timezone;
                DEFAULT_WORKSPACE="${documentDrivePath}/";
              };
              volumes = [
                "${documentDrivePath}/drive:/mnt/storage/drive"
                "${dockerStoragePath}/code:/config"
              ];
          };
        };
      };
    };
  })

  (lib.mkIf (config.builderOptions.docker.nextcloud) 
  {
    # Required: [TODO: create custom dockerfile]
    # ---------------------------------------------------------
    # => chown -R {user.name}:users <dockerStoragePath>/nextcloud
    # => run Nextcloud Installer
    # => sudo docker container exec -it <63f6a18eb605> bash
    # ==> ./occ app:install richdocumentscode
    # ==> ./occ app:enable files_external
    # ==> ./occ app:install files_archive
    # ==> ./occ app:install richdocuments

    networking.firewall.allowedTCPPorts = [ 8080 ];
    virtualisation = {
      docker = { enable = true; enableOnBoot = true; };
      oci-containers = { 
        backend = "docker";
        containers = {
          nextcloud = {
              autoStart = true;
              image = "azamserver/nextcloud-imagemagick-ffmpeg:latest";
              user = uid;
              ports = [ 
                "8080:80"
                ];
              environment = {      
                PHP_UPLOAD_LIMIT="6G";
                PHP_MEMORY_LIMIT="16192M";
                NEXTCLOUD_DATA_DIR="/var/www/html/data";
                TRUSTED_PROXIES="";
              };
              volumes = [
                "${dockerStoragePath}/nextcloud/config:/var/www/html"
                "${dockerStoragePath}/nextcloud/data:/var/www/html/data"
              ];
          };
        };
      };
    };
  })

  (lib.mkIf (config.builderOptions.docker.tailscale) 
  {
    virtualisation = {
      docker = { enable = true; enableOnBoot = true; };
      oci-containers = { 
        backend = "docker";
        containers = {
          tailscale = {
              autoStart = true;
              image = "tailscale/tailscale:v1.52.0";
              user = uid;            
              ports = [ 
                ];
              environment = {
              };
              volumes = [
              ];
          };
        };
      };
    };
  })
];
}
