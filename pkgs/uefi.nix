{
  lib,
  stdenvNoCC,
}:
{
  gpt,
  idbloader,
  fit,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  name = "uefi-edk2-rk3588";

  srcs = [
    gpt
    idbloader
    fit
  ];

  dontUnpack = true;
  dontConfigure = true;

  buildPhase = ''

    ${
      (lib.strings.optionalString (!builtins.isNull gpt) ''
        dd if=${gpt} of=boot.bin bs=1K seek=0
      '')
    }

    dd if=${idbloader} of=boot.bin bs=1K seek=32
    dd if=${fit} of=boot.bin bs=1K seek=1024
  '';

  installPhase = ''
    mkdir $out
    cp -- ./boot.bin $out/
  '';

  dontFixup = true;

  passthru = {
    boot.bin = "${finalAttrs.finalPackage.out}/boot.bin";
  };
})
