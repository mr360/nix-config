{
  stdenvNoCC,
  fetchFromGitHub,
  gtk-engine-murrine,
}:

stdenvNoCC.mkDerivation {
  pname = "chicago95-theme";
  version = "unstable-2023-06-09";

  src = fetchFromGitHub {
    owner = "grassmunk";
    repo = "Chicago95";
    rev = "e9d250b2fa9e4853571b877f6584a33a2f0e9f75";
    hash = "sha256-9KxkkhHS+mq6yoF3+jaThNATJ+IGsohB3PIZN4PQq/A=";
  };
  propagatedUserEnvPkgs = [gtk-engine-murrine];

  installPhase = ''
    mkdir -p $out/share/themes/
    cp --archive 'Theme/Chicago95' $out/share/themes/Chicago95
  '';
}