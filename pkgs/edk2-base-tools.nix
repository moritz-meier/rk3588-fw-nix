{
  libuuid,
  python3,
  stdenv,
  edk2-rk3588-src,
}:
stdenv.mkDerivation {
  name = "edk2-rk3588-base-tools";

  src = edk2-rk3588-src;

  nativeBuildInputs = [
    libuuid
    python3
  ];

  patchPhase = ''
    patchShebangs .
  '';

  configurePhase = ''
    export PACKAGES_PATH="$PWD/edk2:$PWD/edk2-platforms:$PWD/edk2-rockchip:$PWD/devicetree:$PWD/edk2-non-osi:$PWD"
  '';

  buildPhase = ''
    make -C "$PWD/edk2/BaseTools" -j $NIX_BUILD_CORES
  '';

  installPhase = ''
    mkdir $out
    cp -r ./edk2/BaseTools/. $out/
  '';

  dontFixup = true;
}
