{
    lib,
    stdenv,
    fetchzip,
    nodejs_20
}:
let 
    pname = "devcontainer-cli";
    version = "0.80.1";
    hash = "sha256-cIWNKBTsI2bbMCGxvwAqhZMk6kQtn3G5jjKGSLS/24U=";
in
stdenv.mkDerivation {
    inherit pname version;
    
    src = fetchzip {
      inherit hash;
      url = "https://registry.npmjs.org/@devcontainers/cli/-/cli-${version}.tgz";
    };

    dontBuild = true;
    dontConfigure = true;

    installPhase = ''
      mkdir -p $out/bin
      cp -a "$src/." "$out"
      rm devcontainer.js
    '';

    postFixup = ''
      cat <<EOF > $out/bin/devcontainer
      #!${nodejs_20}/bin/node
        require('$out/dist/spec-node/devContainersSpecCLI');
      EOF

      chmod +x $out/bin/devcontainer
    '';

    meta = with lib; {
      homepage = "https://containers.dev";
      description = "A reference implementation for the specification that \
       can create and configure a dev container from a devcontainer.json";
      license = licenses.mit;
      platforms = lib.intersectLists (lib.platforms.linux) (lib.platforms.x86_64);
      maintainers = with maintainers; [ mr360 ];
    };
  }
