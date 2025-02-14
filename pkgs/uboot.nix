{
  stdenv,
  writeText,
  pkgsCross,
  bison,
  flex,
  python3,
  swig,
  openssl,
  gnutls,
  pkg-config,
  uboot-src,
}:
{
  defconfig,
  tpl,
  bl31,
  bl32,
  extraConfig ? ''
    CONFIG_SYS_SPI_U_BOOT_OFFS=0x00100000
    CONFIG_TEXT_BASE=0x00200000
  '',
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

  patchPhase = ''
    patchShebangs ./scripts
    patchShebangs ./tools

    sed -i 's/\/bin\/pwd/pwd/' ./Makefile 
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

    cp ./build/spl/u-boot-spl $out/
    cp ./build/spl/u-boot-spl-dtb.bin $out/
    cp ./build/spl/u-boot-spl.dtb $out/

    cp ./build/idbloader.img $out/
    cp ./build/idbloader-spi.img $out/

    cp ./build/u-boot-rockchip.bin $out/
    cp ./build/u-boot-rockchip-spi.bin $out/

    mkdir $out/bin
    cp ./build/tools/mkimage $out/bin/
  '';

  dontFixup = true;

  passthru = {
    spl.elf = "${finalAttrs.finalPackage.out}/u-boot-spl";
    spl.bin = "${finalAttrs.finalPackage.out}/u-boot-spl-dtb.bin";
    spl.dtb = "${finalAttrs.finalPackage.out}/u-boot-spl.dtb";

    idbloader.bin = "${finalAttrs.finalPackage.out}/idbloader.img";
    idbloader-spi.bin = "${finalAttrs.finalPackage.out}/idbloader-spi.img";

    boot.bin = "${finalAttrs.finalPackage.out}/u-boot-rockchip.bin";
    boot-spi.bin = "${finalAttrs.finalPackage.out}/u-boot-rockchip-spi.bin";
  };
})
