{
  stdenv,
  pkgsCross,
  atf-src,
}:
{
  plat ? "rk3588",

}:
stdenv.mkDerivation {
  name = "arm-trusted-firmware";

  src = atf-src;

  nativeBuildInputs = [
    pkgsCross.aarch64-multiplatform.binutils
    pkgsCross.aarch64-embedded.stdenv.cc.cc
  ];

  dontPatch = true;
  dontConfigure = true;

  buildPhase = ''
    unset AR
    unset AS
    unset CC
    unset CXX
    unset LD
    unset NM
    unset OBJCOPY
    unset OBJDUMP
    unset RANLIB
    unset READELF
    unset SIZE
    unset STRINGS
    unset STRIP

    make CROSS_COMILE=${stdenv.cc.targetPrefix} PLAT=${plat} bl31
  '';

  installPhase = ''
    mkdir $out
    cp ./build/${plat}/release/bl31/bl31.elf $out/bl31.elf
  '';

  dontFixup = true;
}
