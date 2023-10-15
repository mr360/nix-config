{pkgs, ...}: let
  callPackage = pkgs.callPackage;
in {
  nixpkgs.overlays = [(final: prev: {
    localpkgs = {
      themes = {
        goldy-plasma = callPackage ./themes/gtk-theme.nix {};
        chicago95 = callPackage ./themes/chicago95-theme.nix {};
        raleigh-reloaded = callPackage ./themes/raleigh-reloaded-theme.nix {};
      };
    };
  })];
}