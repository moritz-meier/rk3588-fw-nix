{
  dtc,
  pkg-config,
  python3,
  stdenvNoCC,
}:
{
  bl31,
  bl32,
  bl33,
  dtb,
  mkimage,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  name = "edk2-rk3588-fit";

  srcs = [
    bl31
    bl32
    bl33
    dtb
  ];

  nativeBuildInputs = [
    dtc
    mkimage
    pkg-config
    (python3.withPackages (pyPkgs: [ pyPkgs.pyelftools ]))
  ];

  unpackPhase = ''
    cp -- ${../misc/extractbl31.py} ./extractbl31.py
    chmod a+rwx ./extractbl31.py

    mkdir ./source
    cp -- ${../misc/edk2-rk3588.its} ./source/edk2-rk3588.its
    chmod -R a+rwX ./source
    cd ./source
  '';

  patchPhase = ''
    patchShebangs ../extractbl31.py
  '';

  dontConfigure = true;

  buildPhase = ''
    ../extractbl31.py ${bl31}
    if [ ! -f bl31_0x000f0000.bin ]; then
        # Not used but FIT expects it.
        touch bl31_0x000f0000.bin
    fi

    substituteInPlace ./edk2-rk3588.its \
      --subst-var-by "edk2" ${bl33} \
      --subst-var-by "atf-1" ./bl31_0x00040000.bin \
      --subst-var-by "atf-2" ./bl31_0x000f0000.bin \
      --subst-var-by "atf-3" ./bl31_0xff100000.bin \
      --subst-var-by "optee" ${bl32} \
      --subst-var-by "fdt" ${dtb}
      
    mkimage -E -f ./edk2-rk3588.its edk2-rk3588.fit
  '';

  installPhase = ''
    mkdir $out

    cp edk2-rk3588.its $out/
    cp edk2-rk3588.fit $out/
  '';

  dontFixup = true;

  passthru = {
    its = "${finalAttrs.finalPackage.out}/edk2-rk3588.its";
    fit = "${finalAttrs.finalPackage.out}/edk2-rk3588.fit";
  };
})
