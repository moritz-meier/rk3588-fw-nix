{
  runCommand,
  ubootTools,
  edk2-rk3588-src,
}:
{
  tpl,
}:

runCommand "uboot-spl" { nativeBuildInputs = [ ubootTools ]; } ''
  mkdir $out

  mkimage -n rk3588 -T rksd -d ${tpl}/tpl.bin:${edk2-rk3588-src}/misc/rk3588_spl_v1.12.bin $out/idbloader.img

  cp ${edk2-rk3588-src}/misc/rk3588_spl.dtb $out/u-boot-spl.dtb
''
