FROM mcr.microsoft.com/devcontainers/base:jammy
USER vscode

## Resolves: "Session bus not found\nTo circumvent this problem try the following command (with Linux and bash)\nexport $(dbus-launch)"
RUN sudo apt update && sudo apt-get install dbus-x11 -y
RUN echo  'export $(dbus-launch)' >> ~/.bashrc 

## Resolve common X11 application startup dependencies
RUN sudo apt-get install libsm6 libxrender1 libxext6 libgl1 libxcomposite1 libxdamage1 libxrandr2 libfreetype6 libfontconfig1 libxcursor1 libxi6 libxtst6 libxkbcommon0 libasound2 -y
RUN sudo apt-get install '^libxcb.*-dev' libx11-xcb-dev libglu1-mesa-dev libxrender-dev libxi-dev libxkbcommon-dev libxkbcommon-x11-dev -y 

## Review https://github.com/NVlabs/instant-ngp/discussions/300 for further X11 troubleshooting

## Setup IDE
RUN sudo apt-get install -y neovim
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
