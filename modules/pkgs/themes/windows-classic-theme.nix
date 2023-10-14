{
  stdenvNoCC,
  gtk-engine-murrine,
}:

stdenvNoCC.mkDerivation {
  pname = "windows-classic-theme";
  version = "unstable-2023-10-15";

  src = builtins.fetchGit {
    url = /etc/nixos/dotfiles/.local/share/themes;  # Hacky: should use relative pathing  ../../..
    rev = "8b19cb699919effc437309de189d19cbbcc96243";
    ref = "main";
  };
  propagatedUserEnvPkgs = [gtk-engine-murrine];

  installPhase = ''
    mkdir -p $out/share/themes/windows-classic
    cp -R windows-classic/* $out/share/themes/windows-classic
  '';
}