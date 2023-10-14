{
  stdenvNoCC,
  fetchFromGitHub,
  gtk-engine-murrine,
}:

stdenvNoCC.mkDerivation {
  pname = "raleigh-reloaded-theme";
  version = "unstable-2023-10-15";

  src = fetchFromGitHub {
    owner = "mr360";
    repo = "raleigh-reloaded";
    rev = "f3952b93d3a517c42ecafbb86de2f3267ccae2c6";
    hash = "sha256-QYhEQpywZyeoZqZNesOvbrED+/55Q4V7wnodxeuycno=";
  };
  propagatedUserEnvPkgs = [gtk-engine-murrine];

  installPhase = ''
    mkdir -p $out/share/themes/
    cp --archive 'src' $out/share/themes/Raleigh-Reloaded
  '';
}