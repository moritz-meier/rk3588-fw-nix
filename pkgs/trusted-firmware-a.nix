{
  lib,
  pkgsCross,
  stdenvNoCC,
  tfa-src,
}:
{
  plat ? "rk3588",
  logging ? false,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  name = "trusted-firmware-a-${plat}";

  src = tfa-src;

  nativeBuildInputs = [
    pkgsCross.aarch64-embedded.stdenv.cc.cc
    pkgsCross.aarch64-multiplatform.bintools.bintools
  ];

  dontPatch = true;
  dontConfigure = true;

  buildPhase = ''
    make -j $NIX_BUILD_CORES \
      CROSS_COMILE=${pkgsCross.aarch64-embedded.stdenv.cc.targetPrefix} \
      PLAT=${plat} \
      ${lib.strings.optionalString logging "LOG_LEVEL=50"} \
      bl31
  '';

  installPhase = ''
    mkdir $out
    cp -r ./build/. $out/
  '';

  dontFixup = true;

  passthru = {
    elf = "${finalAttrs.finalPackage.out}/${plat}/release/bl31/bl31.elf";
  };
})
