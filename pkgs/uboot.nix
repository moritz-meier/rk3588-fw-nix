{
  pkgsCross,
  uboot-src,
  linux-src,
}:
{
  defconfig,
  tpl,
  bl31,
}:
(pkgsCross.aarch64-multiplatform.buildUBoot {
  inherit defconfig;
  extraMeta.platforms = [ "aarch64-linux" ];
  BL31 = "${bl31}/bl31.elf";
  ROCKCHIP_TPL = "${tpl}/tpl.bin";
  extraConfig = ''
    CONFIG_SYS_SPI_U_BOOT_OFFS=0x00100000
    CONFIG_LOG=y
    CONFIG_SPL_LOG=y
    CONFIG_SPL_LOG_MAX_LEVEL=7
    CONFIG_SPL_LOG_CONSOLE=y
  '';
  filesToInstall = [
    "u-boot.itb"
    "idbloader.img"
    "u-boot-rockchip.bin"
    "u-boot-rockchip-spi.bin"
    "spl/u-boot-spl"
    "spl/u-boot-spl-dtb.bin"
    "spl/u-boot-spl.dtb"
  ];
}).overrideAttrs
  (
    final: prev: {
      src = uboot-src;

      postUnpack = ''
        rm -rf ./source/dts/upstream/arm64/*/
        cp -r -- ${linux-src}/arch/arm64/boot/dts/*/ ./source/dts/upstream/src/arm64/
        chmod -R a+rwX ./source/dts/upstream/src/arm64
      '';

      installPhase =
        prev.installPhase
        + ''
          mkdir $out/bin
          cp ./tools/mkimage $out/bin/
        '';
    }
  )
