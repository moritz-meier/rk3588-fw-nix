{
  stdenv,
  libuuid,
  python3,
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
  '';

  patchPhase = ''
    patchShebangs ./source
  '';

  configurePhase = ''
    cd source

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
