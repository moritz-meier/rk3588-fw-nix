{
  pkgsCross,
  python3,
  stdenv,
  optee-src,
}:
{
}:
stdenv.mkDerivation {
  name = "optee";

  src = optee-src;

  nativeBuildInputs = [
    pkgsCross.aarch64-multiplatform.stdenv.cc.cc
    pkgsCross.aarch64-multiplatform.stdenv.cc.bintools
    pkgsCross.armv7l-hf-multiplatform.stdenv.cc.cc
    pkgsCross.armv7l-hf-multiplatform.stdenv.cc.bintools
    (python3.withPackages (
      pyPkgs: with pyPkgs; [
        cryptography
        pyelftools
      ]
    ))
  ];

  patchPhase = ''
    patchShebangs ./.
  '';
  dontConfigure = true;

  buildPhase = ''
    make -j $NIX_BUILD_CORES \
      CFG_ARM64_core=y \
      CFG_TEE_BENCHMARK=n \
      CROSS_COMPILE=${pkgsCross.aarch64-multiplatform.stdenv.cc.targetPrefix} \
      CROSS_COMPILE_core=${pkgsCross.aarch64-multiplatform.stdenv.cc.targetPrefix} \
      CROSS_COMPILE_ta_arm32=${pkgsCross.armv7l-hf-multiplatform.stdenv.cc.targetPrefix} \
      CROSS_COMPILE_ta_arm64=${pkgsCross.aarch64-multiplatform.stdenv.cc.targetPrefix} \
      PLATFORM=rockchip-rk3588
  '';

  installPhase = ''
    mkdir $out
    cp -R ./out/arm-plat-rockchip/core/tee.elf $out/bl32.elf
    cp -R ./out/arm-plat-rockchip/core/tee.bin $out/bl32.bin
  '';

  dontFixup = true;
}
