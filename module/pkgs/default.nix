{pkgs, ...}: let
  callPackage = pkgs.callPackage;
in {
  nixpkgs.overlays = [(final: prev: {
    localpkgs = {
      themes = {
        chicago95 = callPackage ./themes/chicago95-theme.nix {};
        raleigh-reloaded = callPackage ./themes/raleigh-reloaded-theme.nix {};
      };
    };
  })];
}