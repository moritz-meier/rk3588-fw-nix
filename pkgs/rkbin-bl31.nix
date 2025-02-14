{
  stdenvNoCC,
  rkbin-src,
}:
{
  rktrust-config ? "RK3588TRUST.ini",
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  name = "rkbin-bl31";

  src = rkbin-src;

  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    bl31="./$(grep '^PATH=.*_bl31_' ./RKTRUST/${rktrust-config} | cut -d = -f 2 -)"

    mkdir $out
    cp -- $bl31 $out/bl31.elf
  '';

  dontFixup = true;

  passthru = {
    elf = "${finalAttrs.finalPackage.out}/bl31.elf";
  };
})
