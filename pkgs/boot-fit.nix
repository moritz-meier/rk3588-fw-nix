{
  stdenv,
  dtc,
  python3,
  pkg-config,
  uboot-tools,
}:
{
  bl31,
  bl32,
  uboot,
  edk2,
}:

let
  rk3588-uefi-its = ../misc/rk3588-uefi.its;
  extractbl31 = ../misc/extractbl31.py;
in
stdenv.mkDerivation {
  name = "boot-fit";

  srcs = [
    bl31
    bl32
    uboot
    edk2
  ];

  nativeBuildInputs = [
    uboot-tools
    dtc
    (python3.withPackages (pyPkgs: [ pyPkgs.pyelftools ]))
    pkg-config
  ];

  unpackPhase = ''
    cp -- ${extractbl31} ./extractbl31.py
    chmod a+rwx ./extractbl31.py

    mkdir ./source

    cp -- ${edk2}/FV/BL33_AP_UEFI.Fv ./source/
    cp -- ${bl32}/bl32.bin ./source/
    cp -- ${uboot}/u-boot-spl.dtb ./source/
    cp -- ${rk3588-uefi-its} ./source/rk3588-uefi.its

    chmod -R a+rwX ./source
  '';

  patchPhase = ''
    patchShebangs ./extractbl31.py
  '';

  configurePhase = ''
    cd ./source
  '';

  buildPhase = ''

    ../extractbl31.py ${bl31}/bl31.elf
    if [ ! -f bl31_0x000f0000.bin ]; then
        # Not used but FIT expects it.
        touch bl31_0x000f0000.bin
    fi

    mkimage -E -f rk3588-uefi.its rk3588-uefi.fit
  '';

  installPhase = ''
    mkdir $out

    cp rk3588-uefi.its $out/
    cp rk3588-uefi.fit $out/
  '';

  dontFixup = true;
}
