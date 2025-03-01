{
  acpica-tools,
  dtc,
  edk2-base-tools,
  lib,
  llvmPackages,
  pkgsCross,
  python3,
  stdenvNoCC,
# edk2-rk3588-src,
}:
{
  plat,
  dt-src ? null,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  name = "edk2-rk3588";

  src = edk2-base-tools;

  nativeBuildInputs = [
    acpica-tools
    dtc
    llvmPackages.libcxxClang
    pkgsCross.aarch64-multiplatform.bintools
    pkgsCross.aarch64-multiplatform.stdenv.cc
    python3
  ];

  buildInputs = [ ];

  hardeningDisable = [
    "format"
  ];

  GCC_AARCH64_PREFIX = pkgsCross.aarch64-multiplatform.stdenv.cc.targetPrefix;

  patchPhase =
    ''
      patchShebangs .
    ''
    + lib.strings.optionalString (!builtins.isNull dt-src) ''
      cp -rv --update=all -- ${dt-src}/* ./devicetree/mainline/upstream
    '';

  configurePhase = ''
    export WORKSPACE="$PWD/workspace"
    export PACKAGES_PATH="$PWD/edk2:$PWD/edk2-platforms:$PWD/edk2-rockchip:$PWD/devicetree:$PWD/edk2-non-osi:$PWD"

    config=$(grep -rl 'PLATFORM_NAME=${plat}' ./configs/)
    dsc=$(grep '^DSC_FILE=' $config | cut -d = -f 2 -)
    export PLATFORM="$PWD/$dsc"

    source "$PWD/edk2/edksetup.sh" BaseTools
  '';

  buildPhase = ''
    build -a AARCH64 -b RELEASE -t GCC -p $PLATFORM -n $NIX_BUILD_CORES \
      -D FIRMWARE_VER="unknown" \
      -D DEFAULT_KEYS=TRUE \
      -D PK_DEFAULT_FILE=${../keys}/pk.cer \
      -D KEK_DEFAULT_FILE1=${../keys}/ms_kek.cer \
      -D DB_DEFAULT_FILE1=${../keys}/ms_db1.cer \
      -D DB_DEFAULT_FILE2=${../keys}/ms_db2.cer \
      -D DBX_DEFAULT_FILE1=${../keys}/arm64_dbx.bin \
      -D SECURE_BOOT_ENABLE=TRUE \
      -D NETWORK_ALLOW_HTTP_CONNECTIONS=TRUE \
      -D NETWORK_ISCSI_ENABLE=TRUE \
      -D INCLUDE_TFTP_COMMAND=TRUE \
      --pcd gRockchipTokenSpaceGuid.PcdFitImageFlashAddress=0x100000
  '';

  installPhase = ''
    mkdir $out
    cp -r ./workspace/. $out/
  '';

  dontFixup = true;

  passthru = {
    fw = "${finalAttrs.finalPackage.out}/Build/${plat}/RELEASE_GCC/FV/BL33_AP_UEFI.Fv";
  };
})
