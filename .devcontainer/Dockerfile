FROM mcr.microsoft.com/devcontainers/base:jammy
USER vscode

RUN sudo apt update

## Setup IDE
RUN curl -L https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage > ~/nvim-linux-x86_64.appimage
RUN chmod u+x ~/nvim-linux-x86_64.appimage
RUN mkdir ~/.config/nvim

RUN sudo ~/nvim-linux-x86_64.appimage --appimage-extract
RUN sudo ln -s /squashfs-root/AppRun /usr/bin/nvim

RUN curl -L https://vscode.download.prss.microsoft.com/dbazure/download/stable/cd4ee3b1c348a13bafd8f9ad8060705f6d4b9cba/vscode_cli_alpine_x64_cli.tar.gz > ~/vscode-cli.tar.gz
RUN sudo tar -xf ~/vscode-cli.tar.gz -C /usr/bin
RUN rm ~/vscode-cli.tar.gz

## Passthrough SSH agent configuration
RUN cat <<'EOF' >>~/.bash_profile
if [ -z "$SSH_AUTH_SOCK" ]; then
   RUNNING_AGENT="`ps -ax | grep 'ssh-agent -s' | grep -v grep | wc -l | tr -d '[:space:]'`"
   if [ "$RUNNING_AGENT" = "0" ]; then
        ssh-agent -s &> $HOME/ssh-agent.log
   fi
   eval `cat $HOME/ssh-agent.log` > /dev/null
   ssh-add $HOME/.ssh/id_ed25519_git 2> /dev/null
fi
EOF

#####################|-----------------------------------------|#####################
#####################|   Start Custom Dockerfile setup below   |#####################
#####################|-----------------------------------------|#####################
RUN mkdir ~/nix
RUN curl -L https://nixos.org/nix/install > ~/nix/nix_installer.sh
RUN bash -i ~/nix/nix_installer.sh --no-daemon 
