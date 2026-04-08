{
  config,
  lib,
  pkgs,
  serverUrl,
  flakePath,
  ...
}@args:

let
  sshPath = "${flakePath}/dotfile/.cred/user/${config.builderOptions.user.name}/ssh";
  port = 22;
in
{
  options.builderOptions.ssh = {
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
    (lib.mkIf (config.builderOptions.ssh.enable_agent) {
      programs.ssh = {
        startAgent = true;
        knownHosts = {
          github = {
            extraHostNames = [ "github.com" ];
            publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
          };
        };
        extraConfig = ''
          Host github.com
            IdentityFile ${sshPath}/id_ed25519_git
            KexAlgorithms curve25519-sha256@libssh.org
            IdentitiesOnly yes
            AddKeysToAgent yes

          Host ${serverUrl}
            Port ${toString port} 
            IdentityFile ${sshPath}/id_ed25519_git
            IdentitiesOnly yes
            AddKeysToAgent yes                  
        '';
      };
    })
    (lib.mkIf (config.builderOptions.ssh.enable_server) {
      services.openssh = {
        enable = true;
        settings.PasswordAuthentication = false;
        settings.KbdInteractiveAuthentication = false;
      };

      users.users."${config.builderOptions.user.name}".openssh.authorizedKeys.keyFiles = [
        "${sshPath}/authorized_keys"
      ];

      networking.firewall = {
        allowedTCPPorts = lib.mkAfter [ port ];
      };
    })
  ];
}
