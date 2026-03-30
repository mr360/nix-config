{ config, lib, pkgs, ... }: 

let
  uid = toString config.users.users.${config.builderOptions.user.name}.uid;
  gid = toString config.users.groups.users.gid;
  user = "${config.builderOptions.user.name}";
  credentialPath = "/home/${user}/nix-config/dotfile/.cred/user/${user}";
  containerStoragePath = "/mnt/storage/container";
  storageMediaPath = "/mnt/storage/drive";
in
{
  options.builderOptions.container =
  {
      traefik = lib.mkOption {
	description = "Traefik configuration";
	default = {};
	type = lib.types.submodule {
	  options = {
	    enable = lib.mkOption {
	      type = lib.types.bool;
	      default = false;
	      description = "Enable Traefik container";
	    };

	    routes = lib.mkOption {
	      type = lib.types.listOf (lib.types.submodule {
		options = {
		  service = lib.mkOption { type = lib.types.str; };
		  route = lib.mkOption { type = lib.types.str; };
		  entry = lib.mkOption { type = lib.types.str; default = "web"; };
		  loadBalancerServer = lib.mkOption { type = lib.types.str; };
		};
	      });
	      default = [];
	      description = "Traefik routes";
	    };
	  };
	};
      };

      jellyfin = lib.mkOption {
      default = false;
      example = true;
      type = lib.types.bool;
      description = ''
          Enable jellyfin docker image
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

      coder = lib.mkOption {
      default = false;
      example = true;
      type = lib.types.bool;
      description = ''
          Enable coder docker image
      '';

      };   
      qbittorrent = lib.mkOption {
      default = false;
      example = true;
      type = lib.types.bool;
      description = ''
          Enable qbittorrent docker image
      '';
      };   
      
      minipaint = lib.mkOption {
      default = false;
      example = true;
      type = lib.types.bool;
      description = ''
          Enable minipaint docker image
      '';
      };   

      ferdium = lib.mkOption {
      default = false;
      example = true;
      type = lib.types.bool;
      description = ''
          Enable ferdium docker image
      '';
      };   

      ytdlp = lib.mkOption {
      default = false;
      example = true;
      type = lib.types.bool;
      description = ''
          Enable yt-dlp web interface docker image
	  Please note that this requuires yt-dlp to be installed
      '';
      };   

      serverUrl = lib.mkOption {
      default = "storage-r710.tailb15a6.ts.net";
      example = "server.tailscale.com";
      type = lib.types.string;
      description = ''
         Server url for routing 
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

    users.extraGroups.docker.members = [ "${user}" ];
  }

  (lib.mkIf (config.builderOptions.container.traefik.enable) 
  (let 
  traefikYaml = 
    (pkgs.formats.yaml {}).generate "traefik.yml" {
      http = {
        serversTransports = {
            ignorecert = {
            	insecureSkipVerify = "true";
	    };
	};
	routers =
	  lib.listToAttrs (map (r: {
	    name = "${r.service}-${r.route}";
	    value = {
	      rule = "Host(`${r.route}.${config.builderOptions.container.serverUrl}`)";
	      entryPoints = [ r.entry ];
	      service = r.service;
	      #tls = {
              #  certResolver = "letsencrypt";
	      #};
	    };
	  }) config.builderOptions.container.traefik.routes);

	services =
	  lib.genAttrs
	    (lib.unique (map (r: r.service)
	      config.builderOptions.container.traefik.routes))
	    (name:
	      let
		r = lib.findFirst
		  (x: x.service == name)
		  null
		  config.builderOptions.container.traefik.routes;
	      in {
		loadBalancer.servers = [
		  { url = r.loadBalancerServer; }
		];
	      });
       };
    };

   resolvConf = pkgs.writeText "resolv.conf" ''
    nameserver 1.1.1.1
   '';

  corefile = pkgs.writeText "Corefile" ''
    ${config.builderOptions.container.serverUrl}:53 {
        template IN A {
            match ".*"
            answer "{{ .Name }} 60 IN A 100.94.62.12"
        }

        log
        errors
    }

    .:53 {
        log
        errors
        forward . 1.1.1.1
        cache
    }
  '';
  in
  {
    systemd.tmpfiles.rules = [
        "d ${containerStoragePath}/traefik           0777 ${user} users -"
        "f ${containerStoragePath}/traefik/acme.json 0600 ${user} users -"
    ];
    virtualisation = {
      docker.enable = true;
      oci-containers = { 
        backend = "docker";
        containers = {
          traefik = {
              autoStart = true;
              image = "traefik:v3.6";
              ports = [ 
                "80:8060"
		"443:4443"
              ];
              cmd = [
	        "--api.dashboard=true"
	      	"--providers.docker=true"
		"--providers.file.directory=/dynamic"
		"--providers.file.watch=true"
		"--entrypoints.web.address=:8060"
		
		# DNS Challenge 01
		"--certificatesResolvers.letsencrypt.acme.dnsChallenge.provider=cloudflare"
  		"--certificatesResolvers.letsencrypt.acme.dnsChallenge.resolvers=1.1.1.1:53,1.0.0.1:53"
  		"--certificatesResolvers.letsencrypt.acme.email=mrme360@proton.me"
  		"--certificatesResolvers.letsencrypt.acme.storage=/dynamic/acme.json"
		
		# Https 
		"--entrypoints.web.http.redirections.entrypoint.to=websecure"
                "--entrypoints.web.http.redirections.entrypoint.scheme=https"
                "--entrypoints.web.http.redirections.entrypoint.permanent=true"
		"--entrypoints.websecure.address=:4443"
		"--entrypoints.websecure.http.tls=true"

		# Observability 
                "--log.level=INFO"
                "--accesslog=true"
              ];
	      labels= {
      		"traefik.enable"="true";

	        # Dashboard router
	        "traefik.http.routers.dashboard.rule"="Host(`route.${config.builderOptions.container.serverUrl}`)";
	        "traefik.http.routers.dashboard.entrypoints"="websecure";
	        "traefik.http.routers.dashboard.service"="api@internal";

		# TLS Certificate 
	        "traefik.http.routers.r0.tls.certresolver"="letsencrypt";
	        "traefik.http.routers.r0.tls.domains[0].main"="${config.builderOptions.container.serverUrl}";
	        "traefik.http.routers.r0.tls.domains[0].sans"="*.${config.builderOptions.container.serverUrl}";
	      };
	      extraOptions = [
		"--add-host=host.docker.internal:host-gateway"
	      ];
	      environmentFiles = [
		"${credentialPath}/tailscale/cfToken.env"
  	      ];
              volumes = [
                "/var/run/docker.sock:/var/run/docker.sock:ro"
		"${traefikYaml}:/dynamic/traefik.yaml:ro"
		"${containerStoragePath}/traefik/acme.json:/dynamic/acme.json"
              ];
          };
          coredns = {
              autoStart = true;
              image = "coredns/coredns:1.14.2";
              ports = [ 
                "53:53/udp"
                "53:53/tcp"
              ];
              cmd = [
	        "-conf"
		"/etc/coredns/Corefile"
              ];
              labels = {
	          "traefik.enable" = "false";
              };
              volumes = [
		"${corefile}:/etc/coredns/Corefile"
		"${resolvConf}:/etc/coredns/resolv.conf"
              ];
          };
	};
      };
    };
  }))

  (lib.mkIf (config.builderOptions.container.jellyfin) 
  {
    systemd.tmpfiles.rules = [
        "d ${containerStoragePath}/jellyfin         0777 ${user} users -"
        "d ${containerStoragePath}/jellyfin/config  0777 ${user} users -"
        "d ${containerStoragePath}/jellyfin/data    0777 ${user} users -"
        "d ${containerStoragePath}/jellyfin/cache   0777 ${user} users -"
        "d ${containerStoragePath}/jellyfin/log     0777 ${user} users -"
    ];

    virtualisation = {
      docker.enable = true;
      oci-containers = { 
        backend = "docker";
        containers = {
          jellyfin = {
              autoStart = true;
              image = "linuxserver/jellyfin:10.11.6";
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
              labels = {
	          "traefik.enable" = "true";
		  "traefik.http.routers.jellyfin.rule" = "Host(`media.${config.builderOptions.container.serverUrl}`)";
		  "traefik.http.services.jellyfin.loadbalancer.server.port" = "8096";
		  "traefik.http.routers.jellyfin.entrypoints" = "websecure";
              };
              volumes = [
                "${containerStoragePath}/jellyfin/config:/config"
                "${containerStoragePath}/jellyfin/data:/data"
                "${containerStoragePath}/jellyfin/cache:/cache"
                "${containerStoragePath}/jellyfin/log:/log"
                "${storageMediaPath}/Media/Movie_Shows:/media/library"
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
		"${storageMediaPath}:${storageMediaPath}"
              ];
          };
	  #redis = {}
	  #postgres = {}
	  #office = {}
	  #cron = {}
        };
      };
    };
  })
  
  (lib.mkIf (config.builderOptions.container.coder) 
  {
    systemd.tmpfiles.rules = [
        "d ${containerStoragePath}/coder             0777 ${user} users -"
        "d ${containerStoragePath}/coder/home        0777 ${user} users -"
        "d ${containerStoragePath}/coder/database    0777 ${user} users -"
    ];

    networking.firewall.allowedTCPPorts = lib.mkAfter [ 2080 ];

    virtualisation = {
      docker.enable = true;
      oci-containers = { 
        backend = "docker";
        containers = {
	  database = {
            autoStart = true;
            image = "postgres:17";
    
            environment = {
              POSTGRES_USER = "username";
              POSTGRES_PASSWORD = "password";
              POSTGRES_DB = "coder";
            };
    
            volumes = [
              "${containerStoragePath}/coder/database:/var/lib/postgresql/data"
            ];
    
            # optional if you want external access
             ports = [ "5432:5432" ];
    
            extraOptions = [
            ];
          };
          coder = {
              autoStart = true;
              image = "ghcr.io/coder/coder:v2.31.6";
              ports = [ 
                "2080:2080"
              ];
              environment = {
	      CODER_PG_CONNECTION_URL="postgresql://username:password@172.17.0.9:5432/coder?sslmode=disable";
	      CODER_HTTP_ADDRESS="0.0.0.0:2080";
	      CODER_ACCESS_URL="https://code.${config.builderOptions.container.serverUrl}";
              };
              labels = {
	          "traefik.enable" = "true";
		  "traefik.http.routers.coder.rule" = "Host(`code.${config.builderOptions.container.serverUrl}`)";
		  "traefik.http.services.coder.loadbalancer.server.port" = "2080";
		  "traefik.http.routers.coder.entrypoints" = "websecure";
              };
              volumes = [
                "/var/run/docker.sock:/var/run/docker.sock:rw"
                "${containerStoragePath}/coder/home:/home/coder"
              ];
	      dependsOn = [ "database" ];
	      extraOptions = [
	         "--privileged" # allows Docker in Docker
                 "--group-add=992"
	      ];
          };
        };
      };
    };
  })

  (lib.mkIf (config.builderOptions.container.qbittorrent) 
  {
    virtualisation = {
      docker.enable = true;
      oci-containers = { 
        backend = "docker";
        containers = {
          qbittorrent = {
              autoStart = true;
              image = "linuxserver/qbittorrent:5.1.4";
              ports = [ 
                "8480:8480"
		"6881:6881"
		"6881:6881/udp"
              ];
              environment = {
                PUID= uid;
                PGID= gid;
                TZ=config.time.timeZone;
                WEBUI_PORT= "8480";
                TORRENTING_PORT= "6881";
              };
              labels = {
	          "traefik.enable" = "true";
		  "traefik.http.routers.qbittorrent.rule" = "Host(`torrent.${config.builderOptions.container.serverUrl}`)";
		  "traefik.http.services.qbittorrent.loadbalancer.server.port" = "8480";
		  "traefik.http.routers.qbittorrent.entrypoints" = "websecure";
              };
              volumes = [
                "${containerStoragePath}/qbittorrent/config:/config"
                "/home/${user}/Downloads:/downloads"
              ];
          };
        };
      };
    };
  })

  (lib.mkIf (config.builderOptions.container.minipaint) 
  {
    virtualisation = {
      docker.enable = true;
      oci-containers = { 
        backend = "docker";
        containers = {
          minipaint = {
              autoStart = true;
              image = "pfav/minipaint:v4.11.0";
              ports = [ 
                "8123:80"
              ];
	      cmd = [
	      ];
              environment = {
              };
              labels = {
	          "traefik.enable" = "true";
		  "traefik.http.routers.minipaint.rule" = "Host(`paint.${config.builderOptions.container.serverUrl}`)";
		  "traefik.http.services.minipaint.loadbalancer.server.port" = "80";
		  "traefik.http.routers.minipaint.entrypoints" = "websecure";
              };
              volumes = [
              ];
	      extraOptions = [
  	      ];
          };
        };
      };
    };
  })

  (lib.mkIf (config.builderOptions.container.ferdium) 
  {
    virtualisation = {
      docker.enable = true;
      oci-containers = { 
        backend = "docker";
        containers = {
          ferdium = {
              autoStart = true;
              image = "linuxserver/ferdium:7.1.1";
              ports = [ 
                "3000:3000"
                "3001:3001"
              ];
	      cmd = [
	      ];
              environment = {
                PUID= uid;
                PGID= gid;
                TZ=config.time.timeZone;
	        PIXELFLUX_WAYLAND= "true";
		DRINODE= "/dev/dri/renderD128";
		DRI_NODE= "/dev/dri/renderD128";
                NO_DECOR= "true";
		HARDEN_DESKTOP= "true";
		HARDEN_OPENBOX= "true";
              };
              labels = {
	          "traefik.enable" = "true";
		  "traefik.http.routers.ferdium.rule" = "Host(`inbox.${config.builderOptions.container.serverUrl}`)";
		  "traefik.http.services.ferdium.loadbalancer.server.port" = "3001";
		  "traefik.http.routers.ferdium.entrypoints" = "websecure";

    		  "traefik.http.services.ferdium.loadbalancer.serverstransport" = "ignorecert@file";
                  "traefik.http.services.ferdium.loadbalancer.server.scheme" = "https";
		  "traefik.http.routers.ferdium.tls" = "true";
              };
              volumes = [
                "${containerStoragePath}/ferdium/config:/config"
		"/home/${user}/sync:/sync"
              ];
	      extraOptions = [
                "--shm-size=2gb" 
		"--device=/dev/dri:/dev/dri"
  	      ];
          };
        };
      };
    };
  })

  (lib.mkIf (config.builderOptions.container.ytdlp) 
  (let
  configYml= 
    (pkgs.formats.yaml {}).generate "config.yml" {
	downloadPath= "/downloads";
	require_auth= false;
	downloaderPath= "/usr/local/bin/yt-dlp";
    };
  ytdlp= pkgs.runCommand "yt-dlp-exec" {
    } ''
	    mkdir -p $out/bin
	    cp ${pkgs.fetchurl {
	      url = "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp";
	      sha256 = "sha256-O9oJaKAc3nDSZyBlMAOyhVPHG+FNyy5fTCTpkh/a10U="; 
	    }} $out/bin/yt-dlp
	    chmod +x $out/bin/yt-dlp
    '';
  in
  {
    virtualisation = {
      docker.enable = true;
      oci-containers = { 
        backend = "docker";
        containers = {
          ytdlp = {
              autoStart = true;
              image = "marcobaobao/yt-dlp-webui:latest";
              ports = [ 
                "3033:3033"
              ];
	      cmd = [
	      "-conf" "/etc/config.yml"
	      ];
              environment = {
              };
              labels = {
	          "traefik.enable" = "true";
		  "traefik.http.routers.ytdlp.rule" = "Host(`ytdlp.${config.builderOptions.container.serverUrl}`)";
		  "traefik.http.services.ytdlp.loadbalancer.server.port" = "3033";
		  "traefik.http.routers.ytdlp.entrypoints" = "websecure";
              };
              volumes = [
                "/home/${user}/Downloads:/downloads"
		"${configYml}:/etc/config.yml:ro"
		"${ytdlp}/bin/yt-dlp:/usr/local/bin/yt-dlp"
              ];
	      extraOptions = [
  	      ];
          };
        };
      };
    };
    
  }))
];
}
