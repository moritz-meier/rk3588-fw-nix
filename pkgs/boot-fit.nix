{
  stdenv,
  ubootTools,
  dtc,
}:
{
  bl31,
  bl32,
  uboot,
  edk2,
}:

let
  rk3588-uefi-its = ./misc/rk3588-uefi.its;
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
    ubootTools
    dtc
  ];

  unpackPhase = ''
    mkdir ./source

    cp ${bl31}/bl31.elf ./source/
    cp ${bl32}/bl32.bin ./source/
    cp ${uboot}/u-boot-spl.dtb ./source/
    cp ${edk2}/FV/BL33_AP_UEFI.Fv ./source/

    chmod -R a+rwX ./source
  '';

  dontPatch = true;

  configurePhase = ''
    cd ./source

    substitute ${rk3588-uefi-its} ./rk3588-uefi.its
      --subst-var-by-name EDK2 ./BL33_AP_UEFI.Fv
      --subst-var-by-name BL31 ./bl31.elf
      --subst-var-by-name BL32 ./bl32.bin
      --subst-var-by-name SPL_DTB ./u-boot-spl.dtb

    ls -lah
    cat ./uefi.its
  '';

  buildPhase = '''';

  installPhase = ''
    mkdir $out
  '';

  dontFixup = true;
}
