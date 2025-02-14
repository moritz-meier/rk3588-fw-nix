{
  libuuid,
  python3,
  stdenv,
  edk2-rk3588-src,
}:
stdenv.mkDerivation rec {
  name = "edk2-base-tools";

  src = edk2-rk3588-src;

  nativeBuildInputs = [
    libuuid
    python3
  ];

  unpackPhase = ''
    cp -r -- ${src}/ ./source
    chmod -R a+rwX ./source
    cd ./source
  '';

  patchPhase = ''
    patchShebangs .
  '';

  configurePhase = ''
    export PACKAGES_PATH=edk2:
    export EDK_TOOLS_PATH=edk2/BaseTools
    source edk2/edksetup.sh BaseTools
  '';

  buildPhase = ''
    make -C edk2/BaseTools -j $NIX_BUILD_CORES
  '';

  installPhase = ''
    mkdir $out
    cp -r edk2/BaseTools/* $out/
  '';

  dontFixup = false;
}
