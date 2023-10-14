{
  stdenvNoCC,
  fetchFromGitHub,
  gtk-engine-murrine,
}:

stdenvNoCC.mkDerivation {
  pname = "goldy-plasma-themes";
  version = "unstable-2023-06-09";

  src = fetchFromGitHub {
    owner = "L4ki";
    repo = "Goldy-Plasma-Themes";
    rev = "8f1cb24f22b226632572b222e619922a70d3ee5a";
    hash = "sha256-671/3gqna05zOqqNlg8BBo1hUFzAIZWofSwyRYyJ0k8=";
  };
  propagatedUserEnvPkgs = [gtk-engine-murrine];

  installPhase = ''
    mkdir -p $out/share/themes/
    cp --archive 'Goldy GTK Themes' $out/share/themes/Goldy-Dark-GTK
  '';
}