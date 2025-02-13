{
  lib,
  stdenv,
  buildPackages,
  runCommand,
  atf-src,
}:
{
  plat ? "rk3588",
  logging ? false,
}:
let
  x =
    runCommand "arm-trusted-firmware"
      {
        nativeBuildInputs = [
          stdenv.cc.cc
          buildPackages.pkgsCross.aarch64-multiplatform.bintools.bintools
        ];
      }
      ''
        cp -r -- ${atf-src} ./source
        chmod a+rwX ./source
        cd ./source

        make -j $NIX_BUILD_CORES \
          CROSS_COMILE=${stdenv.cc.targetPrefix} \
          PLAT=${plat} \
          ${lib.strings.optionalString logging "LOG_LEVEL=50"} \
          bl31

        mkdir $out
        cp -- ./build/${plat}/release/bl31/bl31.elf $out/bl31.elf
      '';
in
x // { inherit buildPackages; }
