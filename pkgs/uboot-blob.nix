{
  stdenv,
  autoPatchelfHook,
  edk2-rk3588-src,
}:
{
  tpl,
}:

stdenv.mkDerivation {
  name = "uboot-blobs";

  srcs = [ edk2-rk3588-src ];

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  unpackPhase = ''
    cp ${edk2-rk3588-src}/misc/tools/x86_64/mkimage ./mkimage
    chmod a+rwx ./mkimage'';

  patchPhase = ''
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" ./mkimage
  '';

  dontConfigure = true;
  dontBuild = true;
  installPhase = ''
    mkdir $out

    ./mkimage -n rk3588 -T rksd -d ${tpl}/tpl.bin:${edk2-rk3588-src}/misc/rk3588_spl_v1.12.bin $out/idbloader.img
    cp ${edk2-rk3588-src}/misc/rk3588_spl.dtb $out/u-boot-spl.dtb

    mkdir $out/bin
    cp ./mkimage $out/bin/
  '';
}
