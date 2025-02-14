{ stdenvNoCC, edk2-rk3588-src }:
{ }:
stdenvNoCC.mkDerivation (finalAttrs: rec {
  name = "edk2-rk3588-gpt-blob";

  src = edk2-rk3588-src;

  dontUnpack = true;
  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    mkdir $out

    cp -- ${src}/misc/rk3588_spi_nor_gpt.txt $out/
    cp -- ${src}/misc/rk3588_spi_nor_gpt.img $out/
  '';

  dontFixup = true;

  passthru = {
    txt = "${finalAttrs.finalPackage.out}/rk3588_spi_nor_gpt.txt";
    bin = "${finalAttrs.finalPackage.out}/rk3588_spi_nor_gpt.img";
  };
})
