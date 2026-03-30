{ config, lib, pkgs, ... }:

let
  user = config.builderOptions.user.name;
  keyFile = "/home/${user}/nix-config/dotfile/.cred/licence/btsync.btskey";
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
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Folders to share in headless mode via Resilio Sync";
    };
  };

  config = lib.mkIf config.builderOptions.sync.enable {
    users.users.${user}.extraGroups = lib.mkAfter [ "rslsync" ];

    networking.firewall.allowedTCPPorts = lib.mkAfter [ sharePort webUIPort ];
    networking.firewall.allowedUDPPorts = lib.mkAfter [ sharePort ];

    systemd.tmpfiles.rules = [
        "d ${syncDataPath}                   0777 ${user} users -"
        "C ${syncDataPath}/licence.btskey    0777 ${user} users - ${builtins.path { path = keyFile; }}"
    ];

    services.resilio = {
      enable = true;
      checkForUpdates = false;
      enableWebUI = config.builderOptions.sync.folders == [];
      httpListenPort = webUIPort;
      httpListenAddr = "0.0.0.0";
      storagePath = syncDataPath;
      listeningPort = sharePort;
      httpPass = "";
      httpLogin = "";
      deviceName = config.networking.hostName;
      #sharedFolders = [{
	 #   secret         = "the key"; 
	 #   directory      = sharedDirectory;
	 #   knownHosts     = ["${config.builderOptions.container.serverUrl}:${sharePort}"];
	 #   useRelayServer = false;
	 #   useTracker     = false;
	 #   useDHT         = false;
	 #   searchLAN      = true;
	 #   useSyncTrash   = true;
	 # }];
    };

    builderOptions.container.traefik.routes = [{
    	service = "rslsync";
	route = "sync";
	entry = "websecure";
	loadBalancerServer = "http://host.docker.internal:${toString webUIPort}";
    }];

    #TODO: design flow for user portion if needed
    #  sync = {  
    #    enable = true;
    #    folders = [
    #     {
    #       directory = "";
    #       secret = "";
    #       hostUrl = "xyz";
    #     } 
    #    ];
    #  }
    #
  };
}
