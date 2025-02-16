{
  stdenvNoCC,
  rkbin-src,
}:
{
  rkboot-config ? "RK3588MINIALL.ini",
}:

stdenvNoCC.mkDerivation (finalAttrs: rec {
  name = "rkbin-tpl";

  src = rkbin-src;

  dontUnpack = true;
  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    tpl="${src}/$(grep '^FlashData' ${src}/RKBOOT/${rkboot-config} | cut -d = -f 2 -)"

    mkdir $out
    cp -- $tpl $out/tpl.bin
  '';

  dontFixup = true;

  passthru = {
    bin = "${finalAttrs.finalPackage.out}/tpl.bin";
  };
})
