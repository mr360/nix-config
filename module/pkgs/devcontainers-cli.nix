{
    lib,
    stdenv,
    fetchzip,
    nodejs_18
}:
let 
    pname = "devcontainers-cli";
    version = "unstable-0.54.1";
in
stdenv.mkDerivation {
    inherit pname version ;
    
    src = fetchzip {
      url = "https://github.com/mr360/cli/releases/download/v0.54.1/x86_64-node18-devcontainers-cli-0.54.1.tar.gz";
      hash = "sha256-fq11G0Q2Xy56MtgqN8DX4zFL/9Ge7NaoHqHjkZGsOC0=";
    };

    nativeBuildInputs = [ 
    ];

    dontBuild = true;
    dontConfigure = true;

    installPhase = ''
      mkdir -p $out/bin
      cp -a "$src/." "$out"
      rm devcontainer.js
    '';

    postFixup = ''
      cat <<EOF > $out/bin/devcontainer
      #!${nodejs_18}/bin/node
        require('$out/dist/spec-node/devContainersSpecCLI');
      EOF

      chmod a+x $out/bin/devcontainer
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