{
  config,
  lib,
  pkgs,
  serverUrl,
  flakePath,
  ...
}:

let
  uid = toString config.users.users.${config.builderOptions.user.name}.uid;
  gid = toString config.users.groups.users.gid;
  user = "${config.builderOptions.user.name}";
  containerUIDs = {
    redis   = "999";
  };

  containerGIDs = {
    redis   = "999";
  };

  credentialPath = "${flakePath}/dotfile/.cred";
  containerStoragePath = "/mnt/storage/container";
  storageMediaPath = "/mnt/storage/drive";
  internalNetwork = "internal-container-network";
in
{
  options.builderOptions.container = {
    traefik = lib.mkOption {
      description = "Traefik configuration";
      default = { };
      type = lib.types.submodule {
        options = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable Traefik container";
          };

          routes = lib.mkOption {
            type = lib.types.listOf (
              lib.types.submodule {
                options = {
                  service = lib.mkOption { type = lib.types.str; };
                  route = lib.mkOption { type = lib.types.str; };
                  entry = lib.mkOption {
                    type = lib.types.str;
                    default = "web";
                  };
                  loadBalancerServer = lib.mkOption { type = lib.types.str; };
                };
              }
            );
            default = [ ];
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

    onlyoffice = lib.mkOption {
      default = false;
      example = true;
      type = lib.types.bool;
      description = ''
        Enable onlyoffice docker image
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
  };

  config = lib.mkMerge [
    {
      systemd.tmpfiles.rules = [
        "d ${containerStoragePath}  0755 ${user} users -"
      ];

      systemd.services.create-docker-network = {
        description = "container shared docker network";
        after = [ "docker.service" ];
        requires = [ "docker.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.docker}/bin/docker network inspect ${internalNetwork} >/dev/null 2>&1 || ${pkgs.docker}/bin/docker network create ${internalNetwork}'";
        };
      };

      systemd.services.docker.serviceConfig.ExecStartPost = [
        "${pkgs.bash}/bin/bash -c '${pkgs.docker}/bin/docker network inspect ${internalNetwork} >/dev/null 2>&1 || ${pkgs.docker}/bin/docker network create ${internalNetwork}'"
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

    (lib.mkIf (config.builderOptions.container.traefik.enable) (
      let
        traefikYaml = (pkgs.formats.yaml { }).generate "traefik.yml" {
          http = {
            middlewares = {
              common-header = {
                headers = {
                  customRequestHeaders = {
                    X-Forwarded-Proto = "https";
                  };
                };
              };
            };
            serversTransports = {
              ignorecert = {
                insecureSkipVerify = "true";
              };
            };
            routers = lib.listToAttrs (
              map (r: {
                name = "${r.service}-${r.route}";
                value = {
                  rule = "Host(`${r.route}.${serverUrl}`)";
                  entryPoints = [ r.entry ];
                  service = r.service;
                  #tls = {
                  #  certResolver = "letsencrypt";
                  #};
                };
              }) config.builderOptions.container.traefik.routes
            );

            services =
              lib.genAttrs (lib.unique (map (r: r.service) config.builderOptions.container.traefik.routes))
                (
                  name:
                  let
                    r = lib.findFirst (x: x.service == name) null config.builderOptions.container.traefik.routes;
                  in
                  {
                    loadBalancer.servers = [
                      { url = r.loadBalancerServer; }
                    ];
                  }
                );
          };
        };

        resolvConf = pkgs.writeText "resolv.conf" ''
          nameserver 1.1.1.1
        '';

        corefile = pkgs.writeText "Corefile" ''
          ${serverUrl}:53 {
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
          "d ${containerStoragePath}/traefik           0755 ${uid} ${gid} -"
          "f ${containerStoragePath}/traefik/acme.json 0600 ${uid} ${gid} -"
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
                  "80:80"
                  "443:443"
                ];
                cmd = [
                  "--api.dashboard=true"
                  "--providers.docker=true"
                  "--providers.file.directory=/dynamic"
                  "--providers.file.watch=true"
                  "--entrypoints.web.address=:80"

                  # DNS Challenge 01
                  "--certificatesResolvers.letsencrypt.acme.dnsChallenge.provider=cloudflare"
                  "--certificatesResolvers.letsencrypt.acme.dnsChallenge.resolvers=1.1.1.1:53,1.0.0.1:53"
                  "--certificatesResolvers.letsencrypt.acme.email=mrme360@proton.me"
                  "--certificatesResolvers.letsencrypt.acme.storage=/dynamic/acme.json"

                  # Https
                  "--entrypoints.web.http.redirections.entrypoint.to=websecure"
                  "--entrypoints.web.http.redirections.entrypoint.scheme=https"
                  "--entrypoints.web.http.redirections.entrypoint.permanent=true"
                  "--entrypoints.websecure.http.middlewares=common-header@file"
                  "--entrypoints.websecure.address=:443"
                  "--entrypoints.websecure.http.tls=true"

                  # Observability
                  "--log.level=INFO"
                  "--accesslog=true"
                ];
                labels = {
                  "traefik.enable" = "true";

                  # Dashboard router
                  "traefik.http.routers.dashboard.rule" = "Host(`route.${serverUrl}`)";
                  "traefik.http.routers.dashboard.entrypoints" = "websecure";
                  "traefik.http.routers.dashboard.service" = "api@internal";

                  # TLS Certificate
                  "traefik.http.routers.r0.entrypoints" = "websecure";
                  "traefik.http.routers.r0.tls" = "true";
                  "traefik.http.routers.r0.tls.certresolver" = "letsencrypt";
                  "traefik.http.routers.r0.tls.domains[0].main" = "${serverUrl}";
                  "traefik.http.routers.r0.tls.domains[0].sans" = "*.${serverUrl}";
                };
                extraOptions = [
                  "--add-host=host.docker.internal:host-gateway"
                  "--network=${internalNetwork}"
                ];
                environmentFiles = [
                  "${credentialPath}/env/cfToken.env"
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
                extraOptions = [
                  "--network=${internalNetwork}"
                ];
                volumes = [
                  "${corefile}:/etc/coredns/Corefile"
                  "${resolvConf}:/etc/coredns/resolv.conf"
                ];
              };
            };
          };
        };
      }
    ))

    (lib.mkIf (config.builderOptions.container.jellyfin) {
      systemd.tmpfiles.rules = [
        "d ${containerStoragePath}/jellyfin         0755 ${uid} ${gid} -"
        "d ${containerStoragePath}/jellyfin/config  0755 ${uid} ${gid} -"
        "d ${containerStoragePath}/jellyfin/data    0755 ${uid} ${gid} -"
        "d ${containerStoragePath}/jellyfin/cache   0755 ${uid} ${gid} -"
        "d ${containerStoragePath}/jellyfin/log     0755 ${uid} ${gid} -"
      ];

      virtualisation = {
        docker.enable = true;
        oci-containers = {
          backend = "docker";
          containers = {
            jellyfin = {
              autoStart = true;
              image = "linuxserver/jellyfin:10.11.6";
              environment = {
                PUID = uid;
                PGID = gid;
                TZ = config.time.timeZone;
                JELLYFIN_LOG_DIR = "/log";
                JELLYFIN_DATA_DIR = "/data";
                JELLYFIN_CONFIG_DIR = "/config";
                JELLYFIN_CACHE_DIR = "/cache";
              };
              labels = {
                "traefik.enable" = "true";
                "traefik.http.routers.jellyfin.rule" = "Host(`media.${serverUrl}`)";
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
              extraOptions = [
                "--network=${internalNetwork}"
              ];
            };
          };
        };
      };
    })

    (lib.mkIf (config.builderOptions.container.onlyoffice) {
      systemd.tmpfiles.rules = [
        "d ${containerStoragePath}/onlyoffice                             0755 ${uid} ${gid} -"
        "d ${containerStoragePath}/onlyoffice/DocumentServer/data         0755 ${uid} ${gid} -"
        "d ${containerStoragePath}/onlyoffice/DocumentServer/logs         0755 ${uid} ${gid} -"
        "d ${containerStoragePath}/onlyoffice/CommunityServer/data        0755 ${uid} ${gid} -"
        "d ${containerStoragePath}/onlyoffice/CommunityServer/logs        0755 ${uid} ${gid} -"
        "d ${containerStoragePath}/onlyoffice/CommunityServer/letsencrypt 0755 ${uid} ${gid} -"
        "d ${containerStoragePath}/onlyoffice/mysql/conf.d                0755 ${uid} ${gid} -"
        "d ${containerStoragePath}/onlyoffice/mysql/data                  0755 ${uid} ${gid} -"
        "d ${containerStoragePath}/onlyoffice/mysql/initdb                0755 ${uid} ${gid} -"
      ];

      virtualisation = {
        docker.enable = true;
        oci-containers = {
          backend = "docker";
          containers = {
            onlyoffice-mysql = {
              image = "mysql:9.6.0";
              autoStart = true;
              environment = {
                MYSQL_DATABASE = "onlyoffice";
              };
              environmentFiles = [
                "${credentialPath}/env/onlyoffice.env"
              ];
              volumes = [
                "${containerStoragePath}/onlyoffice/mysql/conf.d:/etc/mysql/conf.d"
                "${containerStoragePath}/onlyoffice/mysql/data:/var/lib/mysql"
                "${containerStoragePath}/onlyoffice/mysql/initdb:/docker-entrypoint-initdb.d"
              ];
              extraOptions = [
                "--network=${internalNetwork}"
              ];
            };
            # TODO: Fix issue with systemd hard requirement
            # no easy way to get this running
            # manually have to override entrypoint and run scripts without
            # systemd
            onlyoffice-community = {
              image = "onlyoffice/communityserver:12.7.1.1942";
              autoStart = true;
              environment = {
                MYSQL_SERVER_DB_NAME = "onlyoffice";
                MYSQL_SERVER_HOST = "onlyoffice-mysql";
                DOCUMENT_SERVER_PORT_80_TCP_ADDR = "onlyoffice-documentserver";
              };
              environmentFiles = [
                "${credentialPath}/env/onlyoffice.env"
              ];
              volumes = [
                "${containerStoragePath}/onlyoffice/CommunityServer/data:/var/www/onlyoffice/Data"
                "${containerStoragePath}/onlyoffice/CommunityServer/logs:/var/log/onlyoffice"
                "${containerStoragePath}/onlyoffice/CommunityServer/letsencrypt:/etc/letsencrypt"
                "/sys/fs/cgroup:/sys/fs/cgroup:ro"
              ];
              labels = {
                "traefik.enable" = "true";
                "traefik.http.routers.onlyoffice-community.rule" = "Host(`office.${serverUrl}`)";
                "traefik.http.services.onlyoffice-community.loadbalancer.server.port" = "80";
                "traefik.http.routers.onlyoffice-community.entrypoints" = "websecure";
              };
              extraOptions = [
                "--network=${internalNetwork}"
              ];
              dependsOn = [
                "onlyoffice-mysql"
                "onlyoffice-documentserver"
              ];
            };

            onlyoffice-documentserver = {
              image = "onlyoffice/documentserver:9.3";
              autoStart = true;
              environment = {
                JWT_ENABLED = "true";
                JWT_HEADER = "Authorization";
              };
              environmentFiles = [
                "${credentialPath}/env/onlyoffice.env"
              ];
              volumes = [
                "${containerStoragePath}/onlyoffice/DocumentServer/data:/var/www/onlyoffice/Data"
                "${containerStoragePath}/onlyoffice/DocumentServer/logs:/var/log/onlyoffice"
              ];
              labels = {
                "traefik.enable" = "true";
                "traefik.http.routers.onlyoffice-documentserver.rule" =
                  "Host(`internal-onlyoffice-ds.${serverUrl}`)";
                "traefik.http.services.onlyoffice-documentserver.loadbalancer.server.port" = "80";
                "traefik.http.routers.onlyoffice-documentserver.entrypoints" = "websecure";
              };
              extraOptions = [
                "--network=${internalNetwork}"
              ];
            };
          };
        };
      };
    })

    (lib.mkIf (config.builderOptions.container.nextcloud) {
      # Required: [TODO: create custom dockerfile]
      # ---------------------------------------------------------
      # => run Nextcloud Installer
      # => sudo docker container exec -it <63f6a18eb605> bash
      # ==> ./occ app:enable files_external
      # ==> ./occ app:install files_archive
      # ==> ./occ app:install onlyoffice

      systemd.tmpfiles.rules = [
        "d ${containerStoragePath}/nextcloud         0755 ${uid} ${gid} -"
        "d ${containerStoragePath}/nextcloud/config  0755 ${uid} ${gid} -"
        "d ${containerStoragePath}/nextcloud/data    0755 ${uid} ${gid} -"
        "d ${containerStoragePath}/nextcloud/db      0755 ${uid} ${gid} -"
        "d ${containerStoragePath}/nextcloud/redis   0755 ${containerUIDs.redis} ${containerGIDs.redis}  -"
      ];

      virtualisation = {
        docker.enable = true;
        oci-containers = {
          backend = "docker";
          containers = {
            nextcloud = {
              autoStart = true;
              image = "linuxserver/nextcloud:33.0.1";
              environment = {
                PUID = "1000";
                PGID = "100";
                TZ = "Australia/Melbourne";

                PHP_UPLOAD_LIMIT = "6G";
                PHP_MEMORY_LIMIT = "16192M";

                MYSQL_HOST = "nextcloud-mariadb:3306";
                REDIS_HOST = "nextcloud-redis";
                MYSQL_DATABASE = "nextcloud";

                DOCKER_MODS = "linuxserver/mods:universal-package-install";
                INSTALL_PACKAGES = "imagemagick";
              };
              environmentFiles = [
                "${credentialPath}/env/nextcloud.env"
              ];
              labels = {
                "traefik.enable" = "true";
                "traefik.http.routers.nextcloud.rule" = "Host(`cloud.${serverUrl}`)";
                "traefik.http.services.nextcloud.loadbalancer.server.port" = "80";
                "traefik.http.routers.nextcloud.entrypoints" = "websecure";
              };
              volumes = [
                "${containerStoragePath}/nextcloud/config:/config"
                "${containerStoragePath}/nextcloud/data:/data"
                "${storageMediaPath}:${storageMediaPath}"
              ];
              dependsOn = [
                "nextcloud-mariadb"
                "nextcloud-redis"
              ];
              extraOptions = [
                "--network=${internalNetwork}"
              ];
            };

            nextcloud-mariadb = {
              image = "linuxserver/mariadb:11.4.9";
              autoStart = true;
              environment = {
                PUID = "1000";
                PGID = "100";
                TZ = "Australia/Melbourne";
                MYSQL_DATABASE = "nextcloud";
              };
              volumes = [
                "${containerStoragePath}/nextcloud/db:/config"
                "${containerStoragePath}/nextcloud/db/custom.cnf:/config/custom.cnf"
              ];
              environmentFiles = [
                "${credentialPath}/env/nextcloud.env"
              ];
              extraOptions = [
                "--network=${internalNetwork}"
              ];
            };

            nextcloud-redis = {
              image = "redis:alpine3.23";
              autoStart = true;
              cmd = [
                "redis-server"
                "--appendonly"
                "yes"
                "--maxmemory"
                "512mb"
                "--maxmemory-policy"
                "allkeys-lru"
              ];
              volumes = [
                "${containerStoragePath}/nextcloud/redis:/data"
              ];
              extraOptions = [
                "--network=${internalNetwork}"
              ];
            };
          };
        };
      };
    })

    (lib.mkIf (config.builderOptions.container.coder) {
      systemd.tmpfiles.rules = [
        "d ${containerStoragePath}/coder             0755 ${uid} ${gid} -"
        "d ${containerStoragePath}/coder/home        0755 ${uid} ${gid} -"
        "d ${containerStoragePath}/coder/database    0755 ${uid} ${gid} -"
      ];

      virtualisation = {
        docker.enable = true;
        oci-containers = {
          backend = "docker";
          containers = {
            coder-postgresdb = {
              autoStart = true;
              image = "postgres:17";

              environment = {
                POSTGRES_DB = "coder";
              };

              volumes = [
                "${containerStoragePath}/coder/database:/var/lib/postgresql/data"
              ];
              environmentFiles = [
                "${credentialPath}/env/coder.env"
              ];
              extraOptions = [
                "--network=${internalNetwork}"
              ];
            };
            coder = {
              autoStart = true;
              image = "ghcr.io/coder/coder:v2.31.6";
              environment = {
                CODER_HTTP_ADDRESS = "0.0.0.0:2080";
                CODER_ACCESS_URL = "https://code.${serverUrl}";
              };
              labels = {
                "traefik.enable" = "true";
                "traefik.http.routers.coder.rule" = "Host(`code.${serverUrl}`)";
                "traefik.http.services.coder.loadbalancer.server.port" = "2080";
                "traefik.http.routers.coder.entrypoints" = "websecure";
              };
              volumes = [
                "/var/run/docker.sock:/var/run/docker.sock:rw"
                "${containerStoragePath}/coder/home:/home/coder"
              ];
              environmentFiles = [
                "${credentialPath}/env/coder.env"
              ];
              dependsOn = [ "coder-postgresdb" ];
              extraOptions = [
                "--network=${internalNetwork}"
                "--privileged" # allows Docker in Docker
                "--group-add=992"
              ];
            };
          };
        };
      };
    })

    (lib.mkIf (config.builderOptions.container.qbittorrent) {
      virtualisation = {
        docker.enable = true;
        oci-containers = {
          backend = "docker";
          containers = {
            qbittorrent = {
              autoStart = true;
              image = "linuxserver/qbittorrent:5.1.4";
              ports = [
                "6881:6881"
                "6881:6881/udp"
              ];
              environment = {
                PUID = uid;
                PGID = gid;
                TZ = config.time.timeZone;
                WEBUI_PORT = "8480";
                TORRENTING_PORT = "6881";
              };
              labels = {
                "traefik.enable" = "true";
                "traefik.http.routers.qbittorrent.rule" = "Host(`torrent.${serverUrl}`)";
                "traefik.http.services.qbittorrent.loadbalancer.server.port" = "8480";
                "traefik.http.routers.qbittorrent.entrypoints" = "websecure";
              };
              volumes = [
                "${containerStoragePath}/qbittorrent/config:/config"
                "/home/${user}/Downloads:/downloads"
              ];
              extraOptions = [
                "--network=${internalNetwork}"
              ];
            };
          };
        };
      };
    })

    (lib.mkIf (config.builderOptions.container.minipaint) {
      virtualisation = {
        docker.enable = true;
        oci-containers = {
          backend = "docker";
          containers = {
            minipaint = {
              autoStart = true;
              image = "pfav/minipaint:v4.11.0";
              cmd = [
              ];
              environment = {
              };
              labels = {
                "traefik.enable" = "true";
                "traefik.http.routers.minipaint.rule" = "Host(`paint.${serverUrl}`)";
                "traefik.http.services.minipaint.loadbalancer.server.port" = "80";
                "traefik.http.routers.minipaint.entrypoints" = "websecure";
              };
              volumes = [
              ];
              extraOptions = [
                "--network=${internalNetwork}"
              ];
            };
          };
        };
      };
    })

    (lib.mkIf (config.builderOptions.container.ferdium) {
      virtualisation = {
        docker.enable = true;
        oci-containers = {
          backend = "docker";
          containers = {
            ferdium = {
              autoStart = true;
              image = "linuxserver/ferdium:7.1.1";
              cmd = [
              ];
              environment = {
                PUID = uid;
                PGID = gid;
                TZ = config.time.timeZone;
                PIXELFLUX_WAYLAND = "true";
                DRINODE = "/dev/dri/renderD128";
                DRI_NODE = "/dev/dri/renderD128";
                NO_DECOR = "true";
                HARDEN_DESKTOP = "true";
                HARDEN_OPENBOX = "true";
              };
              labels = {
                "traefik.enable" = "true";
                "traefik.http.routers.ferdium.rule" = "Host(`inbox.${serverUrl}`)";
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
                "--network=${internalNetwork}"
                "--shm-size=1gb"
                "--device=/dev/dri:/dev/dri"
              ];
            };
          };
        };
      };
    })

    (lib.mkIf (config.builderOptions.container.ytdlp) (
      let
        configYml = (pkgs.formats.yaml { }).generate "config.yml" {
          downloadPath = "/downloads";
          require_auth = false;
          downloaderPath = "/usr/local/bin/yt-dlp";
        };
        ytdlp =
          pkgs.runCommand "yt-dlp-exec"
            {
            }
            ''
              	    mkdir -p $out/bin
              	    cp ${
                     pkgs.fetchurl {
                       url = "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp";
                       sha256 = "sha256-O9oJaKAc3nDSZyBlMAOyhVPHG+FNyy5fTCTpkh/a10U=";
                     }
                   } $out/bin/yt-dlp
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
                image = "marcobaobao/yt-dlp-webui:sha256-41be2e1ed6fbee5278039f09d6116c5f5f6c587f219ae75ceb11234522bee5bc.sig";
                cmd = [
                  "-conf"
                  "/etc/config.yml"
                ];
                environment = {
                };
                labels = {
                  "traefik.enable" = "true";
                  "traefik.http.routers.ytdlp.rule" = "Host(`ytdlp.${serverUrl}`)";
                  "traefik.http.services.ytdlp.loadbalancer.server.port" = "3033";
                  "traefik.http.routers.ytdlp.entrypoints" = "websecure";
                };
                volumes = [
                  "/home/${user}/Downloads:/downloads"
                  "${configYml}:/etc/config.yml:ro"
                  "${ytdlp}/bin/yt-dlp:/usr/local/bin/yt-dlp"
                ];
                extraOptions = [
                  "--network=${internalNetwork}"
                ];
              };
            };
          };
        };

      }
    ))
  ];
}
