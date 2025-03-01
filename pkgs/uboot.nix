{
  bison,
  flex,
  gnutls,
  lib,
  openssl,
  pkg-config,
  pkgsCross,
  python3,
  stdenv,
  swig,
  writeText,
  uboot-src,
}:
{
  defconfig,
  tpl,
  bl31,
  bl32,
  dt-src ? null,
  extraConfig ? '''',
}:
let
  extraConfigFile = writeText ".extra-config" extraConfig;
in
stdenv.mkDerivation (finalAttrs: {
  name = "uboot-${defconfig}";

  srcs = uboot-src;

  nativeBuildInputs = [
    bison
    flex
    pkgsCross.aarch64-multiplatform.stdenv.cc
    (python3.withPackages (
      pyPkgs: with pyPkgs; [
        setuptools
        pyelftools
      ]
    ))
    swig
    openssl
    gnutls
    pkg-config
  ];

  env = {
    BL31 = "${bl31}";
    TEE = "${bl32}";
    ROCKCHIP_TPL = "${tpl}";
  };

  patchPhase =
    ''
      patchShebangs ./scripts
      patchShebangs ./tools

      sed -i 's/\/bin\/pwd/pwd/' ./Makefile
    ''
    + lib.strings.optionalString (!builtins.isNull dt-src) ''
      cp -rv --update=all -- ${dt-src}/* ./dts/upstream
    '';

  configurePhase = ''
    export KBUILD_OUTPUT=build
    export CROSS_COMPILE=${pkgsCross.aarch64-multiplatform.stdenv.cc.targetPrefix}
    make ${defconfig}

    cat ${extraConfigFile} >> $KBUILD_OUTPUT/.config
  '';

  buildPhase = ''
    make -j $NIX_BUILD_CORES
  '';

  installPhase = ''
    mkdir $out
    cp -r ./build/. $out/

    mkdir $out/bin
    cp ./build/tools/mkimage $out/bin/
  '';

  dontFixup = true;

  passthru = {
    spl.elf = "${finalAttrs.finalPackage.out}/spl/u-boot-spl";
    spl.bin = "${finalAttrs.finalPackage.out}/spl/u-boot-spl-dtb.bin";
    spl.dtb = "${finalAttrs.finalPackage.out}/spl/u-boot-spl.dtb";

    idbloader.bin = "${finalAttrs.finalPackage.out}/idbloader.img";
    idbloader-spi.bin = "${finalAttrs.finalPackage.out}/idbloader-spi.img";

    boot.bin = "${finalAttrs.finalPackage.out}/u-boot-rockchip.bin";
    boot-spi.bin = "${finalAttrs.finalPackage.out}/u-boot-rockchip-spi.bin";
  };
})
