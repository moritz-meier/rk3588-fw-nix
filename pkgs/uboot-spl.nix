{
  fetchgit,
  runCommand,
  ubootTools,
}:
{
  tpl,
  edk2-rk3588-src ? fetchgit {
    url = "https://github.com/edk2-porting/edk2-rk3588.git";
    hash = "sha256-3awEMdFMGYsH18/wjQDkpMoZgWc4sfnm4ttgUof4fl4=";
    fetchSubmodules = true;
  },
}:

runCommand "uboot-spl" { nativeBuildInputs = [ ubootTools ]; } ''
  mkdir $out

  mkimage -n rk3588 -T rksd -d ${tpl}/tpl.bin:${edk2-rk3588-src}/misc/rk3588_spl_v1.12.bin $out/idbloader.img

  cp ${edk2-rk3588-src}/misc/rk3588_spl.dtb $out/u-boot-spl.dtb
''
