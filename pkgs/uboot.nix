{ fetchFromGitLab, pkgsCross }:
{
  defconfig,
  tpl,
  bl31,
  uboot-src ? fetchFromGitLab {
    domain = "gitlab.collabora.com";
    owner = "hardware-enablement/rockchip-3588";
    repo = "u-boot";
    rev = "rk3588";
    hash = "sha256-pO3Lcjlgt0wRe2r0HVRIB/KlyQiwYh4mIZ6Zc5Paut0=";
  },
  linux-src ? fetchFromGitLab {
    domain = "gitlab.collabora.com";
    owner = "hardware-enablement/rockchip-3588";
    repo = "linux";
    rev = "rk3588";
    hash = "sha256-t+dtZHyIpPGd/ED/GiQTr9GMTUeBefH8cDt6KuHTmpw=";
  },
}:
(pkgsCross.aarch64-multiplatform.buildUBoot {
  inherit defconfig;
  extraMeta.platforms = [ "aarch64-linux" ];
  BL31 = "${bl31}/bl31.elf";
  ROCKCHIP_TPL = "${tpl}/tpl.bin";
  filesToInstall = [
    "u-boot.itb"
    "idbloader.img"
    "u-boot-rockchip.bin"
    "u-boot-rockchip-spi.bin"
    "spl/u-boot-spl-dtb.bin"
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
    }
  )
