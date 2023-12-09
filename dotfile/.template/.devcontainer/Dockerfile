FROM mcr.microsoft.com/devcontainers/base:jammy
USER vscode

RUN mkdir ~/nix
RUN curl -L https://nixos.org/nix/install > ~/nix/nix_installer.sh
RUN bash -i ~/nix/nix_installer.sh --no-daemon

## Resolves: "Session bus not found\nTo circumvent this problem try the following command (with Linux and bash)\nexport $(dbus-launch)"
RUN sudo apt update && sudo apt install dbus-x11 -y
RUN echo  'export $(dbus-launch)' >> ~/.bashrc 