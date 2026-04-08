{
  config,
  lib,
  pkgs,
  serverUrl,
  flakePath,
  ...
}:

let
  user = config.builderOptions.user.name;
  keyFile = "${flakePath}/dotfile/.cred/licence/btsync.btskey";
  syncDataPath = "/mnt/storage/service/resilio-sync";
  webUIPort = 9116;
  sharePort = 55555;
in
{
  options.builderOptions.sync = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable syncing folders with Resilio Sync";
    };

    folders = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule (
          { ... }:
          {
            options = {
              directory = lib.mkOption {
                type = lib.types.str;
                description = "Directory to sync.";
              };

              secret = lib.mkOption {
                type = lib.types.str;
                description = "Secret used for syncing.";
              };
            };
          }
        )
      );
      default = [ ];
      description = "Folders to share in headless mode via Resilio Sync";
    };
  };

  config = lib.mkIf config.builderOptions.sync.enable {
    users.users.${user}.extraGroups = lib.mkAfter [ "rslsync" ];

    networking.firewall.allowedTCPPorts = lib.mkAfter [
      sharePort
      webUIPort
    ];
    networking.firewall.allowedUDPPorts = lib.mkAfter [ sharePort ];

    systemd.tmpfiles.rules = [
      "d ${syncDataPath}                   0777 ${user} users -"
      "C ${syncDataPath}/licence.btskey    0777 ${user} users - ${builtins.path { path = keyFile; }}"
    ];

    services.resilio = {
      enable = true;
      checkForUpdates = false;
      enableWebUI = config.builderOptions.sync.folders == [ ];
      httpListenPort = webUIPort;
      httpListenAddr = "0.0.0.0";
      storagePath = syncDataPath;
      listeningPort = sharePort;
      httpPass = "";
      httpLogin = "";
      deviceName = config.networking.hostName;
      sharedFolders = map (folder: {
        secret = folder.secret;
        directory = folder.directory;
        knownHosts = [ "${serverUrl}:${sharePort}" ];
        useRelayServer = false;
        useTracker = false;
        useDHT = false;
        searchLAN = true;
        useSyncTrash = true;
      }) config.builderOptions.sync.folders;
    };

    builderOptions.container.traefik.routes = [
      {
        service = "rslsync";
        route = "sync";
        entry = "websecure";
        loadBalancerServer = "http://host.docker.internal:${toString webUIPort}";
      }
    ];
  };
}
