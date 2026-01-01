{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      treefmt-nix,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ self.overlays.default ];
      };

      treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;

    in
    {
      packages.${system} = rec {
        rkbin-loader = pkgs.rkbin-loader { };
        rkbin-tpl = pkgs.rkbin-tpl { };
        rkbin-bl31 = pkgs.rkbin-bl31 { };
        rkbin-bl32 = pkgs.rkbin-bl32 { };

        tfa = pkgs.pkgsCross.aarch64-multiplatform.trusted-firmware-a {
          plat = "rk3588";
        };

        optee = pkgs.pkgsCross.aarch64-multiplatform.optee-os {
          plat = "rockchip-rk3588";
        };

        uboot = pkgs.pkgsCross.aarch64-multiplatform.uboot {
          defconfig = "orangepi-5-plus-rk3588_defconfig";
          extraMakeFlags = [
            "ROCKCHIP_TPL=${rkbin-tpl.bin}"
            "BL31=${tfa.elf}"
            "TEE=${optee.elf}"
          ];

          outputFiles = {
            idbloader = "idbloader.img";
            idbloader-spi = "idbloader-spi.img";
          };
        };

        uboot-tools = pkgs.pkgsCross.aarch64-multiplatform.uboot-tools;

        edk2-rk3588 =
          let
            edk2-rk3588-src-patched = pkgs.applyPatches {
              name = "edk2-rk3588-src-patched";
              src = pkgs.edk2-rk3588-src;

              postPatch = ''
                for patch_file in "./edk2-patches/*.patch"; do
                  patch -p1 -d ./edk2 < $patch_file
                done
              '';
            };
          in
          pkgs.pkgsCross.aarch64-multiplatform.edk2 {
            dsc = "edk2-rockchip/Platform/OrangePi/OrangePi5Plus/OrangePi5Plus.dsc";
            buildConfig = "RELEASE";
            src = edk2-rk3588-src-patched;
            packagesPath = [
              "devicetree"
              "edk2"
              "edk2-non-osi"
              "edk2-platforms"
              "edk2-rockchip"
              "edk2-rockchip-non-osi"
            ];

            extraBuildFlags = [
              "-D FIRMWARE_VER=${edk2-rk3588-src-patched.rev}"
              "-D DEFAULT_KEYS=TRUE"
              "-D PK_DEFAULT_FILE=${./keys/pk.cer}"
              "-D KEK_DEFAULT_FILE1=${./keys/ms_kek.cer}"
              "-D DB_DEFAULT_FILE1=${./keys/ms_db1.cer}"
              "-D DB_DEFAULT_FILE2=${./keys/ms_db2.cer}"
              "-D DBX_DEFAULT_FILE1=${./keys/arm64_dbx.bin}"
              "-D SECURE_BOOT_ENABLE=TRUE"
              "-D NETWORK_ALLOW_HTTP_CONNECTIONS=TRUE"
              "-D NETWORK_ISCSI_ENABLE=TRUE"
              "-D INCLUDE_TFTP_COMMAND=TRUE"
              "--pcd gRockchipTokenSpaceGuid.PcdFitImageFlashAddress=0x100000"
            ];
          };
      };

      devShells.${system} = {
        default = pkgs.mkShell {
          packages = [
            pkgs.qemu_full
            pkgs.pkgsCross.aarch64-multiplatform.stdenv.cc
          ];
        };
      };

      # for `nix fmt`
      formatter.${system} = treefmtEval.config.build.wrapper;

      # for `nix flake check`
      checks.${system}.formatting = treefmtEval.config.build.check self;

      overlays.default = import ./pkgs.nix;
    };
}
