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
  credentials = builtins.fromJSON (
    builtins.readFile "${flakePath}/dotfile/.cred/services/btsync/credentials.json"
  );
  syncDataPath = "/mnt/storage/service/resilio-sync";
  syncDownloadPath = "/mnt/sync";
  syncHomePath = "/home/${user}/sync";
  webUIPort = 9116;
  sharePort = 55555;

  dockerHostGateway = config.builderOptions.container.network.dockerBridgeAddress;
  dockerInternalNetworkSubnet = config.builderOptions.container.network.dockerInternalSubnet;

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
                description = "Secret key to query secret value used for syncing.";
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

    networking.firewall.allowedTCPPorts = lib.mkAfter [ sharePort ];
    networking.firewall.allowedUDPPorts = lib.mkAfter [ sharePort ];
    networking.firewall.extraCommands = if config.builderOptions.sync.folders == [ ] then
    ''
        iptables -A INPUT -p tcp -s ${dockerInternalNetworkSubnet} --dport ${toString webUIPort} -j ACCEPT
    '' else '''';

    system.activationScripts.setHomeGroupPerms = {
      deps = [ "users" ];
      text = ''
        chown ${user}:rslsync /home/${user}
        chmod 0770 /home/${user}
      '';
    };

    systemd.tmpfiles.rules = [
      "d ${syncDataPath}                     0770 ${user} rslsync -"
      "Z ${syncDataPath}                     0770 ${user} rslsync -"
      "C ${syncDataPath}/licence.btskey      0770 ${user} rslsync -   ${builtins.path { path = keyFile; }}"
      # Expose ~/sync at /mnt/sync via symlink; setgid on ~/sync so new files inherit rslsync group
      "L ${syncDownloadPath}                 -    -       -       -   ${syncHomePath}"
      "Z ${syncHomePath}                     2770 ${user} rslsync -"
    ] ++ map (folder: "Z ${folder.directory} 2770 ${user} rslsync -") config.builderOptions.sync.folders;

    systemd.services.resilio.preStart = ''
      if [ ! -f ${syncDataPath}/setup_done ]; then 
        ${lib.getExe config.services.resilio.package} --nodaemon --identity ${config.networking.hostName} --storage ${syncDataPath}
        ${lib.getExe config.services.resilio.package} --nodaemon --license ${syncDataPath}/licence.btskey --storage ${syncDataPath}
        touch ${syncDataPath}/setup_done 
      fi 
    '';

    services.resilio = {
      enable = true;
      checkForUpdates = false;
      enableWebUI = config.builderOptions.sync.folders == [ ];
      httpListenPort = webUIPort;
      httpListenAddr = dockerHostGateway;
      storagePath = syncDataPath;
      listeningPort = sharePort;
      httpPass = credentials.password;
      httpLogin = credentials.username;
      deviceName = config.networking.hostName;
      sharedFolders = map (folder: {
        secret = credentials.secrets.${folder.secret};
        directory = folder.directory;
        knownHosts = [ "${serverUrl}:${toString sharePort}" ];
        useRelayServer = false;
        useTracker = true;
        useDHT = false;
        searchLAN = true;
        useSyncTrash = false;
      }) config.builderOptions.sync.folders;
    };

    builderOptions.container.traefik.routes = [
      {
        service = "rslsync";
        route = "sync";
        entry = "websecure";
        loadBalancerServer = "http://host.docker.internal:${toString webUIPort}";
        headers = [ "Authorization:Basic ${credentials.authToken}" ];
      }
    ];
  };
}
