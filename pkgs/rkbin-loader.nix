{
  stdenvNoCC,
  rkbin-src,
}:
{
  rkboot-config ? "RK3588MINIALL.ini",
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  name = "rkbin-loader";

  src = rkbin-src;

  dontPatch = true;
  dontConfigure = true;

  buildPhase = ''
    ./tools/boot_merger RKBOOT/${rkboot-config}
  '';

  installPhase = ''
    loader="./$(grep '^PATH=.*_loader_.*\.bin' ./RKBOOT/${rkboot-config} | cut -d = -f 2 -)"

    mkdir $out
    cp -- $loader $out/spl-loader.bin
  '';

  dontFixup = true;

  passthru = {
    bin = "${finalAttrs.finalPackage.out}/spl-loader.bin";
  };
})
