{
  stdenv
, lib
, fetchurl
, dpkg
, makeWrapper
, autoPatchelfHook
, libX11
, mesa
, zlib, libwebp, glib, libbsd, libGL, freetype, systemdMinimal
, libXfont2, libxshmfence,libjpeg_turbo, gnutls, libpng, libass, libevdev, libXcursor, libXrandr, 
  libXext, libXi, libxcb, libXrender, libxcrypt-legacy
,  openssl, pixman, xorg, libunwind
, perlPackages

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

in 
stdenv.mkDerivation {
  pname = "kasm-vnc";
  version = "unstable-2023-10-20-12";

  src = fetchurl {
    url = "https://github.com/kasmtech/KasmVNC/releases/download/v1.2.0/kasmvncserver_jammy_1.2.0_amd64.deb";
    hash = "sha256-B3J8U6N75T67CFbQgrq7ibYyQTQr7mqy5a188WBXChE=";
  };


  nativeBuildInputs = [ 
    dpkg  
    autoPatchelfHook  
    makeWrapper
    libXfont2 libxshmfence
    pixman
    libXcursor
    libXrandr
    libXext  libXi  libxcb  libXrender xorg.libXtst libxcrypt-legacy libunwind 
    perlPackages.perl
  ];

  buildInputs = [
    libX11
    mesa
    zlib libwebp glib libbsd libGL freetype systemdMinimal 
          libjpeg_turbo
      libwebp
      gnutls
      libpng
      libass
      libevdev
      openssl
  ];


  unpackPhase = "dpkg-deb -x $src $out";

  dontBuild = true;
  dontConfigure = true;
  dontPatchELF = false;
  dontAutoPatchelf = false;
  

  installPhase = ''
    runHook preInstall

    mv "$out/usr/lib" "$out/lib"
    ln -s ${lib.getLib openssl}/lib/libssl.so $out/lib/libssl.so.1.1
    ln -s ${lib.getLib openssl}/lib/libcrypto.so $out/lib/libcrypto.so.1.1

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
    wrapProgram "$out/bin/vncserver" \
    --prefix PATH : "${lib.makeBinPath [ perlPackages.perl ]}" \
    --set PERL5LIB "$out/share/perl5:${perlPackages.makePerlPath perlLibs}"
  '';


  meta = with lib; {
    homepage = "https://kasmweb.com/kasmvnc";
    description = "A modern open source VNC server.Connect to your Linux server's desktop from any web browser.";
    license = licenses.gpl2Plus;
    platforms = lib.intersectLists (lib.platforms.linux) (lib.platforms.x86_64);
    maintainers = with maintainers; [ mr360 ];
  };
}