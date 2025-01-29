{
  fetchgit,
  stdenv,
  autoPatchelfHook,
}:

let
  edk2-rk3588-src = fetchgit {
    url = "https://github.com/edk2-porting/edk2-rk3588.git";
    hash = "sha256-3awEMdFMGYsH18/wjQDkpMoZgWc4sfnm4ttgUof4fl4=";
    fetchSubmodules = true;
  };
in

stdenv.mkDerivation {
  name = "uboot-tools";
  srcs = [ ];

  nativeBuildInputs = [ autoPatchelfHook ];

  unpackPhase = ''
    cp ${edk2-rk3588-src}/misc/tools/x86_64/mkimage ./
    chmod a+rwx ./mkimage
  '';

  dontPatch = true;

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    cp ./mkimage $out/bin/
  '';
}

# {
#   fetchFromGitLab,
#   pkgsCross,
#   rkbin-tpl,
#   rkbin-bl31,
# }:
# let
#   uboot-src = fetchFromGitLab {
#     domain = "gitlab.collabora.com";
#     owner = "hardware-enablement/rockchip-3588";
#     repo = "u-boot";
#     rev = "rk3588";
#     hash = "sha256-pO3Lcjlgt0wRe2r0HVRIB/KlyQiwYh4mIZ6Zc5Paut0=";
#   };
# in
# (pkgsCross.aarch64-multiplatform.buildUBoot {
#   defconfig = "orangepi-5-plus-rk3588_defconfig";
#   extraMeta.platforms = [ "aarch64-linux" ];
#   BL31 = "${rkbin-bl31 { }}/bl31.elf";
#   ROCKCHIP_TPL = "${rkbin-tpl { }}/tpl.bin";
#   extraConfig = ''
#     CONFIG_SYS_SPI_U_BOOT_OFFS=0x00100000
#   '';
#   filesToInstall = [
#     "u-boot.itb"
#     "idbloader.img"
#     "u-boot-rockchip.bin"
#     "u-boot-rockchip-spi.bin"
#     "spl/u-boot-spl-dtb.bin"
#     "spl/u-boot-spl.dtb"
#   ];
# }).overrideAttrs
#   (
#     final: prev: {
#       src = uboot-src;

#       installPhase = ''
#         mkdir -p $out/bin/

#         cp ./tools/mkimage $out/bin/
#       '';
#     }
#   )
