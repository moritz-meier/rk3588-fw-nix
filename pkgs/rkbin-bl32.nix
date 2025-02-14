{
  stdenvNoCC,
  rkbin-src,
}:
{
  rktrust-config ? "RK3588TRUST.ini",
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  name = "rkbin-bl32";

  src = rkbin-src;

  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    bl32="./$(grep '^PATH=.*_bl32_' ./RKTRUST/${rktrust-config} | cut -d = -f 2 -)"

    mkdir $out
    cp -- $bl32 $out/bl32.bin
  '';

  dontFixup = true;

  passthru = {
    bin = "${finalAttrs.finalPackage.out}/bl32.bin";
  };
})
