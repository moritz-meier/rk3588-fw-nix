{
  buildPackages,
  fetchFromGitHub,
  lib,
  stdenv,

  optee-ftpm-src,
}:
{
  optee,
  src ? optee-ftpm-src,
  outputFiles ? { },
}:

stdenv.mkDerivation (finalAttrs: rec {
  name = "optee-ftpm";
  version = src.rev;

  inherit src;

  nativeBuildInputs = [
    (buildPackages.python3.withPackages (
      p: with p; [
        cryptography
      ]
    ))
  ];

  makeFlags =
    let
      ms-tpm-src = fetchFromGitHub {
        owner = "microsoft";
        repo = "ms-tpm-20-ref";
        rev = "98b60a44aba79b15fcce1c0d1e46cf5918400f6a";
        hash = "sha256-s3VbhbFCcnXiZ+QZfC7b9Sw+ribYHNPEMcx8db9t09Q=";
      };
    in
    [
      "CROSS_COMPILE=${stdenv.cc.targetPrefix}"
      "CFG_MS_TPM_20_REF=${ms-tpm-src}"
      "TA_DEV_KIT_DIR=${optee}/export-ta_arm64"
      "O=./build"
    ];

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -r ./build/. $out/

    runHook postInstall
  '';

  dontFixup = true;

  passthru =
    { } // (lib.attrsets.mapAttrs (name: value: "${finalAttrs.finalPackage.out}/${value}") outputFiles);
})
