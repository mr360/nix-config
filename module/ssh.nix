{ config, lib, pkgs, ... }@args: 

let 
  isoPrefix = if builtins.hasAttr "config.isoImage" config then "/iso" else "";
in
{
  options.builderOptions.ssh =
  {
    enable_server = lib.mkOption {
      default = false;
      example = true;
      type = lib.types.bool;
      description = ''
        Define whether to run a OpenSSH server. 
        Required if remote-access is needed e.g server
      '';
    };

    enable_agent = lib.mkOption {
      default = true;
      example = true;
      type = lib.types.bool;
      description = ''
        Storing SSH private keys. 
        Required if connecting to remote servers using
        ssh is required.
      '';
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (config.builderOptions.ssh.enable_agent)
    {
        programs.ssh = {
            startAgent = true; 
            knownHosts = {
                github = {
                    extraHostNames = [ "github.com"];
                    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
                };
            };
            extraConfig = ''
                Host github.com
                  IdentityFile ${isoPrefix}/etc/nixos/dotfile/.cred/user/${config.builderOptions.user.name}/ssh/id_ed25519_git
                  IdentitiesOnly yes
                  AddKeysToAgent yes

                Host remote.storage-r710.home
                  Port 22
                  IdentityFile ${isoPrefix}/etc/nixos/dotfile/.cred/user/${config.builderOptions.user.name}/ssh/id_ed25519_git
                  IdentitiesOnly yes
                  AddKeysToAgent yes                  
                '';
        };
    })
    (lib.mkIf (config.builderOptions.ssh.enable_server)
    {
        services.openssh = {
            enable = true;
            settings.PasswordAuthentication = false;
            settings.KbdInteractiveAuthentication = false;
        };

        users.users."${config.builderOptions.user.name}".openssh.authorizedKeys.keyFiles = [
          "${isoPrefix}/etc/nixos/dotfile/.cred/user/${config.builderOptions.user.name}/ssh/authorized_keys"
        ];
    })
  ];
}