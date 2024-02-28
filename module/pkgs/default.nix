{pkgs, ...}: let
  callPackage = pkgs.callPackage;
in {
  nixpkgs.overlays = [(final: prev: {
    localpkgs = {
      drivers = {
        cups-brother-mfcl2800dw = callPackage ./drivers/cups-brother-mfcl2800dw.nix {};
      };
      themes = {
        chicago95 = callPackage ./themes/chicago95-theme.nix {};
        raleigh-reloaded = callPackage ./themes/raleigh-reloaded-theme.nix {};
      };
      devcontainer-cli = callPackage ./devcontainer-cli.nix {};
    };
  })];
}