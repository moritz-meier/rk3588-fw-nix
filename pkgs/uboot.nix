{
  autoPatchelfHook,
  lib,
  pkgsCross,
  uboot-src,
  linux-src,
}:
{
  defconfig,
  tpl,
  bl31,
  logging ? false,
}:
(pkgsCross.aarch64-multiplatform.buildUBoot {
  inherit defconfig;
  src = uboot-src;
  version = uboot-src.rev or "dirt";
  extraMeta.platforms = [ "aarch64-linux" ];
  BL31 = "${bl31}/bl31.elf";
  ROCKCHIP_TPL = "${tpl}/tpl.bin";
  extraConfig = ''
    CONFIG_SYS_SPI_U_BOOT_OFFS=0x00100000
    CONFIG_TEXT_BASE=0x00200000

    ${lib.strings.optionalString logging ''
      CONFIG_LOG=y
      CONFIG_LOG_MAX_LEVEL=9
      CONFIG_LOG_CONSOLE=y
      CONFIG_SPL_LOG=y
      CONFIG_SPL_LOG_MAX_LEVEL=9
      CONFIG_SPL_LOG_CONSOLE=y''}
  '';
  filesToInstall = [
    "u-boot.itb"
    "idbloader.img"
    "u-boot-rockchip.bin"
    "u-boot-rockchip-spi.bin"
    "spl/u-boot-spl"
    "spl/u-boot-spl-dtb.bin"
    "spl/u-boot-spl.dtb"
    ".config"
  ];
}).overrideAttrs
  (
    final: prev: {

      nativeBuildInputs = prev.nativeBuildInputs ++ [ autoPatchelfHook ];

      postPatch =
        prev.postPatch
        + ''
          ls -lah ./

          # rm -rf ./dts/upstream/arm64/*/
          # cp -r -- ${linux-src}/arch/arm64/boot/dts/*/ ./dts/upstream/src/arm64/
          # chmod -R a+rwX ./dts/upstream/src/arm64
        '';

      installPhase =
        prev.installPhase
        + ''
          mkdir $out/bin
          cp ./tools/mkimage $out/bin/
        '';
    }
  )
