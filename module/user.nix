
{config, lib, pkgs, ...}: 

let 
  isoPrefix = if builtins.hasAttr "config.isoImage" config then "/iso" else "";
  home = "/home/${config.builderOptions.user.name}";
  isSyncEnabled = config.builderOptions.sync == true;
in
{
  options.builderOptions.user =
  {
    name = lib.mkOption {
      default = "shady";
      example = "shady";
      type = lib.types.str;
      description = ''
        Name of user to be created.
      '';
    };
  };

  config.users = {
    mutableUsers = false;
    users.${config.builderOptions.user.name} = {
      uid = 1000;
      isNormalUser = true;
      extraGroups = [ 
        "wheel"
        "networkmanager" 
        ];
        
      hashedPasswordFile = "${isoPrefix}/etc/nixos/dotfile/.cred/user/${config.builderOptions.user.name}/hashed.passwd";
    };
  };

  config.system.activationScripts.createInitFolderStruct = if isSyncEnabled then ''
    if test -f ${home}/.sync_setup; then 
      echo "Already set...skipping initial folder creation"
    else
      mkdir -p ${home}/sync/documents
      mkdir -p ${home}/sync/development
      mkdir -p ${home}/sync/downloads/torrent
      mkdir -p ${home}/sync/downloads/browser
      mkdir -p ${home}/sync/media/audio
      mkdir -p ${home}/sync/media/picture/screenshot
      mkdir -p ${home}/sync/media/picture/webcam
      mkdir -p ${home}/sync/media/video/record
      mkdir -p ${home}/sync/other/archive

      rm -R -f ${home}/Pictures    && ln -s ${home}/sync/media/picture ${home}/Pictures
      rm -R -f ${home}/Videos      && ln -s ${home}/sync/media/video ${home}/Videos
      rm -R -f ${home}/Music       && ln -s ${home}/sync/media/audio ${home}/Music
      rm -R -f ${home}/Documents   && ln -s ${home}/sync/documents ${home}/Documents
      rm -R -f ${home}/Development && ln -s ${home}/sync/development ${home}/Development
      rm -R -f ${home}/Downloads   && ln -s ${home}/sync/downloads ${home}/Downloads
      
      chown -R ${config.builderOptions.user.name}:users ${home}/sync/
      echo "createInitFolderStruct" > ${home}/.sync_setup
    fi
  '' else '''';
}

