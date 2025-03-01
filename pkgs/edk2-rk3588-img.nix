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
  name = "edk2-rk3588-img";

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

    dd if=${idbloader} of=edk2-rk3588.bin bs=1K seek=32
    dd if=${fit} of=edk2-rk3588.bin bs=1K seek=1024
  '';

  installPhase = ''
    mkdir $out
    cp -- ./edk2-rk3588.bin $out/
  '';

  dontFixup = true;

  passthru = {
    bin = "${finalAttrs.finalPackage.out}/edk2-rk3588.bin";
  };
})
