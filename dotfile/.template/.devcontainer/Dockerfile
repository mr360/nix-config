FROM mcr.microsoft.com/devcontainers/base:jammy
USER vscode

RUN mkdir ~/nix
RUN curl -L https://nixos.org/nix/install > ~/nix/nix_installer.sh
RUN bash -i ~/nix/nix_installer.sh --no-daemon

## Resolves: "Session bus not found\nTo circumvent this problem try the following command (with Linux and bash)\nexport $(dbus-launch)"
RUN sudo apt update && sudo apt install dbus-x11 -y
RUN echo  'export $(dbus-launch)' >> ~/.bashrc 

## Resolve common X11 application startup dependencies
RUN sudo apt-get install libsm6 libxrender1 libxext6 libgl1 libxcomposite1 libxdamage1 libxrandr2 libfreetype6 libfontconfig1 libxcursor1 libxi6 libxtst6 libxkbcommon0 libasound2 -y
RUN sudo apt-get install '^libxcb.*-dev' libx11-xcb-dev libglu1-mesa-dev libxrender-dev libxi-dev libxkbcommon-dev libxkbcommon-x11-dev -y 

## Review https://github.com/NVlabs/instant-ngp/discussions/300 for further X11 troubleshooting

#####################|-----------------------------------------|#####################
#####################|   Start Custom Dockerfile setup below   |#####################
#####################|-----------------------------------------|#####################
