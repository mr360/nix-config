  { config, lib, pkgs, ... }@args: 

{
  options.custom.ssh =
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
    (lib.mkIf (config.custom.ssh.enable_agent)
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
                  IdentityFile /home/${config.custom.user.name}/.ssh/id_ed25519_git
                  IdentitiesOnly yes
                  AddKeysToAgent yes
                '';
        };
    })
    (lib.mkIf (config.custom.ssh.enable_server)
    {
        services.openssh = {
            enable = true;
            settings.PasswordAuthentication = false;
            settings.KbdInteractiveAuthentication = false;
        };
    })
  ];
}