{
  stdenv
, lib
, fetchurl
, dpkg
, makeWrapper
, autoPatchelfHook
, mesa
, pixman
, openssl
, perlPackages
, xorg 
, libxcrypt-legacy
, glib
, libbsd
, libGL
, freetype
, systemdMinimal
, libunwind
}:

let 
  perlLibs = with perlPackages; [ 
    Switch ListMoreUtils ExporterTiny TryTiny 
    DateTime NamespaceAutoclean BHooksEndOfScope 
    ModuleImplementation ModuleRuntime SubExporterProgressive 
    NamespaceClean PackageStash SubIdentify Specio 
    MROCompat RoleTiny EvalClosure DevelStackTrace
    ParamsValidationCompiler ExceptionClass ClassDataInheritable
    DateTimeLocale FileShareDir ClassInspector DateTimeTimeZone
    ClassSingleton 
    
    YAMLTiny HashMergeSimple
  ];

  xorgLibs = with xorg; [
    libXfont2 libxshmfence libXcursor libXrandr libXext libXi 
    libxcb libXrender libXtst 
  ];

in 
  stdenv.mkDerivation {
    pname = "kasm-vnc";
    version = "unstable-2023-10-20-12";

    src = fetchurl {
      url = "https://github.com/kasmtech/KasmVNC/releases/download/v1.2.0/kasmvncserver_jammy_1.2.0_amd64.deb";
      hash = "sha256-B3J8U6N75T67CFbQgrq7ibYyQTQr7mqy5a188WBXChE=";
    };

    nativeBuildInputs = [ 
      dpkg autoPatchelfHook makeWrapper systemdMinimal 
      perlPackages.perl xorgLibs libxcrypt-legacy libunwind
      glib libbsd libGL freetype
    ];

    dontBuild = true;
    dontConfigure = true;

    unpackPhase = "dpkg-deb -x $src $out";

    installPhase = ''
      runHook preInstall

      mv "$out/usr/lib" "$out/lib"
      ln -s ${lib.getLib openssl}/lib/libssl.so $out/lib/libssl.so.1.1
      ln -s ${lib.getLib openssl}/lib/libcrypto.so $out/lib/libcrypto.so.1.1
      ln -s ${lib.getLib mesa}/lib/libgbm.so $out/lib/libgbm.so.1 
      ln -s ${lib.getLib pixman}/lib/libpixman-1.so $out/lib/libpixman-1.so.0 
      
      mv $out/usr/share $out/share
      
      # Symlink to bin
      mkdir -p $out/bin
      ln -s "$out/usr/bin/kasmvncconfig" $out/bin/vncconfig
      ln -s "$out/usr/bin/kasmvncpasswd" $out/bin/vncpasswd
      ln -s "$out/usr/bin/kasmvncserver" $out/bin/vncserver
      ln -s "$out/usr/bin/kasmxproxy" $out/bin/kasmxproxy
      ln -s "$out/usr/bin/Xkasmvnc" $out/bin/Xvnc

      runHook postInstall
    '';

    postFixup = ''
      mv "$out/bin/vncserver" "$out/bin/.vncserver-wrapped"
      makeWrapper "${perlPackages.perl}/bin/perl" "$out/bin/vncserver" \
      --add-flags "$out/bin/.vncserver-wrapped" \
      --set PERL5LIB "$out/share/perl5:${perlPackages.makePerlPath perlLibs}"
    '';

    # TODO: 
    # - Patch vncserver perl script /usr folders 
    # - Create a systemd service which runs at startup (toggle) 

    meta = with lib; {
      homepage = "https://kasmweb.com/kasmvnc";
      description = "A modern open source VNC server.Connect to your Linux \
      server's desktop from any web browser.";
      license = licenses.gpl2Plus;
      platforms = lib.intersectLists (lib.platforms.linux) (lib.platforms.x86_64);
      maintainers = with maintainers; [ mr360 ];
    };
  }