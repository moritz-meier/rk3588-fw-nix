{
  autoPatchelfHook,
  stdenv,
  edk2-rk3588-src,
}:
{
  tpl,
}:

stdenv.mkDerivation (finalAttrs: rec {
  name = "edk2-rk3588-uboot-spl-blob";

  src = edk2-rk3588-src;

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  unpackPhase = ''
    cp ${src}/misc/tools/x86_64/mkimage ./
    chmod a+rwx ./mkimage

    mkdir ./source
    cp ${src}/misc/rk3588_spl_v1.12.bin ./source/
    cp ${src}/misc/rk3588_spl.dtb ./source/
    chmod a+rwX ./source
    cd ./source
  '';

  patchPhase = ''
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" ../mkimage
  '';

  dontConfigure = true;

  buildPhase = ''
    ../mkimage -n rk3588 -T rksd -d ${tpl}:./rk3588_spl_v1.12.bin idbloader.img
    ../mkimage -n rk3588 -T rkspi -d ${tpl}:./rk3588_spl_v1.12.bin idbloader-spi.img
  '';

  installPhase = ''
    mkdir $out

    cp ./rk3588_spl_v1.12.bin $out/
    cp ./rk3588_spl.dtb $out/

    cp ./idbloader.img $out/
    cp ./idbloader-spi.img $out/

    mkdir $out/bin
    cp ../mkimage $out/bin/
  '';

  dontFixup = true;

  passthru = {
    spl.bin = "${finalAttrs.finalPackage.out}/rk3588_spl_v1.12.bin";
    spl.dtb = "${finalAttrs.finalPackage.out}/rk3588_spl.dtb";

    idbloader.bin = "${finalAttrs.finalPackage.out}/idbloader.img";
    idbloader-spi.bin = "${finalAttrs.finalPackage.out}/idbloader-spi.img";
  };
})
