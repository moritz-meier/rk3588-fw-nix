{
  fetchFromGitLab,
  stdenv,
  pkgsCross,
}:
{
  plat ? "rk3588",
  atf-src ? fetchFromGitLab {
    domain = "gitlab.collabora.com";
    owner = "hardware-enablement/rockchip-3588";
    repo = "trusted-firmware-a";
    rev = "rk3588";
    hash = "sha256-PCUKLfmvIBiJqVmKSUKkNig1h44+4RypZ04BvJ+HP6M=";
  },
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
