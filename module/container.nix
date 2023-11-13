{ config, lib, pkgs, ... }: 

# Manual update of containers every 12 months
# Next update scheduled for 1st Dec 2024
let
  uid = toString config.users.users.${config.builderOptions.user.name}.uid;
  gid = toString config.users.groups.users.gid;
  user = "${config.builderOptions.user.name}";
  containerStoragePath = "/mnt/storage/container";
  documentDrivePath = "/mnt/storage/drive";
in
{
  options.builderOptions.container =
  {
      idrac6 = lib.mkOption {
      default = false;
      example = true;
      type = lib.types.bool;
      description = ''
          Enable IDRAC6 docker image for r710
      '';
      };

      bind9 = lib.mkOption {
      default = false;
      example = true;
      type = lib.types.bool;
      description = ''
          Enable bind9 docker image
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
  };
  
  config = lib.mkMerge [
  {
    systemd.tmpfiles.rules = [
        "d ${containerStoragePath}  0755 ${user} users -"
    ];
    virtualisation = {
	docker = { 
	    enable = lib.mkDefault false;
	    enableOnBoot = true;
	};

	podman = {
	    enable = lib.mkDefault false;
	    dockerCompat = true;
	    dockerSocket.enable = true;
	    defaultNetwork.settings = {
		dns_enabled = true;
	    };
	    autoPrune = {
		enable = true;
		dates = "weekly";
		flags = [ "--all" ];
	    };
	};
    };
  }

  (lib.mkIf (config.builderOptions.container.idrac6)
  {
    systemd.tmpfiles.rules = [
        "d ${containerStoragePath}/idrac              0777 ${user} users -"
        "d ${containerStoragePath}/idrac/app          0777 ${user} users -"
        "d ${containerStoragePath}/idrac/media        0777 ${user} users -"
        "d ${containerStoragePath}/idrac/screenshots  0777 ${user} users -"
    ];
    virtualisation = {
      docker.enable = true;
      oci-containers = { 
        backend = "docker";
        containers = {
          idrac6 = {
              autoStart = true;
              image = "domistyle/idrac6:v0.9";
              ports = [ 
                "5800:5800"
                "5850:5900"
                ];
              environment = {
                IDRAC_HOST = "idrac.storage-r710.home";
                IDRAC_USER = "root";
                IDRAC_PASSWORD = "root";
              };
              volumes = [
                "${containerStoragePath}/idrac/app:/app"
                "${containerStoragePath}/idrac/media:/vmedia"
                "${containerStoragePath}/idrac/screenshots:/screenshots"
              ];
          };
        };
      };
    };
  })
  
  (lib.mkIf (config.builderOptions.container.bind9) 
  {
    # Bind9 docker address needs to be set as secondary
    # whilst server ip is primary DNS within the router.
    
    systemd.tmpfiles.rules = [
        "d ${containerStoragePath}/bind9           0777 ${user} users -"
        "d ${containerStoragePath}/bind9/resource  0777 ${user} users -"
        "d ${containerStoragePath}/bind9/cache     0777 ${user} users -"
        "d ${containerStoragePath}/caddy           0777 ${user} users -"
        "d ${containerStoragePath}/caddy/data      0777 ${user} users -"
        "d ${containerStoragePath}/caddy/config    0777 ${user} users -"
    ];
    networking.firewall.allowedTCPPorts = [ 53 ];
    networking.firewall.allowedUDPPorts = [ 53 ];
    virtualisation = {
      docker.enable = true;
      oci-containers = { 
        backend = "docker";
        containers = {
          bind9 = {
              autoStart = true;
              image = "ubuntu/bind9:9.18-22.04_beta";
              ports = [ 
                "53:53/tcp"
                "53:53/udp"
              ];
              environment = {
                BIND9_USER="root";
                TZ = config.time.timeZone;
              };
              volumes = [
                "/etc/nixos/dotfile/.config/bind9:/etc/bind"
                "${containerStoragePath}/bind9/resource:/var/lib/bind"
                "${containerStoragePath}/bind9/cache:/var/cache/bind"
              ];
          };
          caddy = {
            autoStart = true;
            image = "caddy:2.7";
            ports = [
              "80:80"
            ];
            environment = {
            };
            volumes = [
              "${containerStoragePath}/caddy/data:/data"
              "${containerStoragePath}/caddy/config:/config"
              "/etc/nixos/dotfile/.config/caddy/Caddyfile:/etc/caddy/Caddyfile"

            ];
          };
        };
      };
    };
  })

  (lib.mkIf (config.builderOptions.container.jellyfin) 
  {
    systemd.tmpfiles.rules = [
        "d ${containerStoragePath}/jellyfin         0777 ${user} users -"
        "d ${containerStoragePath}/jellyfin/config  0777 ${user} users -"
        "d ${containerStoragePath}/jellyfin/data    0777 ${user} users -"
        "d ${containerStoragePath}/jellyfin/cache   0777 ${user} users -"
        "d ${containerStoragePath}/jellyfin/log     0777 ${user} users -"
    ];
    networking.firewall.allowedTCPPorts = [ 9001 ];
    virtualisation = {
      docker.enable = true;
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
                TZ=config.time.timeZone;
                JELLYFIN_LOG_DIR = "/log";
                JELLYFIN_DATA_DIR = "/data";
                JELLYFIN_CONFIG_DIR = "/config";
                JELLYFIN_CACHE_DIR = "/cache";
              };
              volumes = [
                "${containerStoragePath}/jellyfin/config:/config"
                "${containerStoragePath}/jellyfin/data:/data"
                "${containerStoragePath}/jellyfin/cache:/cache"
                "${containerStoragePath}/jellyfin/log:/log"
                "${documentDrivePath}/LtsData2/Media/Movie_Shows:/media/library"
              ];
          };
        };
      };
    };
  })

  (lib.mkIf (config.builderOptions.container.code) 
  {
    systemd.tmpfiles.rules = [
        "d ${containerStoragePath}/code             0777 ${user} users -"
        "d ${containerStoragePath}/code/.config     0777 ${user} users -"
        "d ${containerStoragePath}/code/.local      0777 ${user} users -"
        "d ${containerStoragePath}/code/data        0777 ${user} users -"
        "d ${containerStoragePath}/code/extensions  0777 ${user} users -"
        "d ${containerStoragePath}/code/workspace   0777 ${user} users -"
    ];
    networking.firewall.allowedTCPPorts = [ 9002 ];
    virtualisation = {
      docker.enable = true;
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
                TZ=config.time.timeZone;
                DEFAULT_WORKSPACE="${documentDrivePath}/sync";
              };
              volumes = [
                "${documentDrivePath}/sync:/mnt/storage/drive/sync"
                "/etc/nixos/dotfile/.cred/user/${user}/ssh:/config/.ssh"
		"/etc/nixos/dotfile/.config/code-server/.bashrc:/config/.bashrc"
		"${containerStoragePath}/code/.config:/config/.config"
		"${containerStoragePath}/code/.local:/config/.local"
		"${containerStoragePath}/code/data:/config/data"
		"${containerStoragePath}/code/extensions:/config/extensions"
		"${containerStoragePath}/code/workspace:/config/workspace"
              ];
          };
        };
      };
    };
  })

  (lib.mkIf (config.builderOptions.container.nextcloud) 
  {
    # Required: [TODO: create custom dockerfile]
    # ---------------------------------------------------------
    # => run Nextcloud Installer
    # => sudo docker container exec -it <63f6a18eb605> bash
    # ==> ./occ app:install richdocumentscode
    # ==> ./occ app:enable files_external
    # ==> ./occ app:install files_archive
    # ==> ./occ app:install richdocuments

    systemd.tmpfiles.rules = [
        "d ${containerStoragePath}/nextcloud         0777 ${user} users -"
        "d ${containerStoragePath}/nextcloud/config  0777 ${user} users -"
        "d ${containerStoragePath}/nextcloud/data    0777 ${user} users -"
    ];
    networking.firewall.allowedTCPPorts = [ 8080 ];
    virtualisation = {
      docker.enable = true;
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
                "${containerStoragePath}/nextcloud/config:/var/www/html"
                "${containerStoragePath}/nextcloud/data:/var/www/html/data"
		"${documentDrivePath}:${documentDrivePath}"
              ];
          };
        };
      };
    };
  })
];
}
