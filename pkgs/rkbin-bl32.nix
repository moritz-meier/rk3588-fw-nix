{
  stdenvNoCC,
  rkbin-src,
}:
{
  rktrust-config ? "RK3588TRUST.ini",
}:

stdenvNoCC.mkDerivation (finalAttrs: rec {
  name = "rkbin-bl32";

  src = rkbin-src;

  dontUnpack = true;
  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    bl32="${src}/$(grep '^PATH=.*_bl32_' ${src}/RKTRUST/${rktrust-config} | cut -d = -f 2 -)"

    mkdir $out
    cp -- $bl32 $out/bl32.bin
  '';

  dontFixup = true;

  passthru = {
    bin = "${finalAttrs.finalPackage.out}/bl32.bin";
  };
})
