{
  acpica-tools,
  dtc,
  edk2-base-tools,
  lib,
  llvmPackages,
  pkgsCross,
  python3,
  stdenvNoCC,
  edk2-rk3588-src,
  linux-src,
}:
{
  plat,
  useUpstreamDts ? true,
}:
stdenvNoCC.mkDerivation (finalAttrs: rec {
  name = "edk2";

  src = edk2-rk3588-src;

  nativeBuildInputs = [
    python3
    acpica-tools
    llvmPackages.libcxxClang
    pkgsCross.aarch64-multiplatform.stdenv.cc
    pkgsCross.aarch64-multiplatform.bintools
    dtc
  ];

  buildInputs = [ ];

  hardeningDisable = [
    "format"
  ];

  GCC5_AARCH64_PREFIX = pkgsCross.aarch64-multiplatform.stdenv.cc.targetPrefix;

  unpackPhase = ''
    cp -r -- ${src} ./source
    chmod -R a+rwX ./source
    cd ./source
  '';

  patchPhase =
    ''
      patchShebangs .
    ''
    + lib.strings.optionalString useUpstreamDts ''
      rm -rf ./devicetree/mainline/upstream/arm64/*/
      cp -r -- ${linux-src}/arch/arm64/boot/dts/*/ ./devicetree/mainline/upstream/src/arm64/
      chmod -R a+rwX ./devicetree/mainline/upstream/src/arm64/
    '';

  configurePhase = ''
    mkdir -p Conf

    export EDK_TOOLS_PATH=${edk2-base-tools}
    export PACKAGES_PATH="$PWD/edk2:$PWD/edk2-platforms:$PWD/edk2-rockchip:$PWD/devicetree:$PWD/edk2-non-osi:$PWD"

    config=$(grep -rl 'PLATFORM_NAME=${plat}' ./configs/)
    dsc=$(grep '^DSC_FILE=' $config | cut -d = -f 2 -)
    export PLATFORM=$PWD/$dsc

    source edk2/edksetup.sh BaseTools
  '';

  buildPhase = ''
    build -a AARCH64 -b RELEASE -t GCC5 -p $PLATFORM -n $NIX_BUILD_CORES \
      --pcd gRockchipTokenSpaceGuid.PcdFitImageFlashAddress=0x100000 
  '';

  installPhase = ''
    mkdir $out
    cp -r ./Build/${plat}/RELEASE_GCC5/FV/BL33_AP_UEFI.Fv $out/
  '';

  dontFixup = true;

  passthru = {
    fw = "${finalAttrs.finalPackage.out}/BL33_AP_UEFI.Fv";
  };
})
