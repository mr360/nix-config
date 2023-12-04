FROM mcr.microsoft.com/devcontainers/base:jammy
USER vscode

RUN mkdir ~/nix
RUN curl -L https://nixos.org/nix/install > ~/nix/nix_installer.sh
RUN bash -i ~/nix/nix_installer.sh --no-daemon
