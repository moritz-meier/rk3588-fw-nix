{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    rustpkgs = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      rustpkgs,
      treefmt-nix,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          self.overlays.default
          (import rustpkgs)
        ];
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

        optee-ftpm = pkgs.pkgsCross.aarch64-multiplatform.optee-ftpm { inherit optee; };

        httpboot = pkgs.pkgsCross.aarch64-multiplatform.httpboot;

        uboot-rk3588 = pkgs.pkgsCross.aarch64-multiplatform.uboot {
          defconfig = "orangepi-5-plus-rk3588_defconfig";
          extraMakeFlags = [
            "ROCKCHIP_TPL=${rkbin-tpl.bin}"
            "BL31=${tfa.elf}"
            "TEE=${optee.elf}"
          ];

          extraConfig = ''
            CONFIG_LOG=y
            CONFIG_CMD_LOG=y
            CONFIG_LOG_DEFAULT_LEVEL=4
            CONFIG_LOG_MAX_LEVEL=7
            CONFIG_LOG_CONSOLE=y

            CONFIG_ENV_IS_NOWHERE=n
            CONFIG_ENV_IS_IN_SPI_FLASH=y
            CONFIG_ENV_OFFSET=0x800000

            CONFIG_NET_LWIP=y

            CONFIG_WGET_HTTPS=y

            CONFIG_EFI_HTTP_BOOT=y

            CONFIG_CMD_GPT=y
            CONFIG_CMD_GPT_RENAME=y
            CONFIG_CMD_EFIDEBUG=y
          '';

          outputFiles = {
            boot-bin = "u-boot-rockchip.bin";
            boot-spi-bin = "u-boot-rockchip-spi.bin";
          };
        };

        uboot-virt = pkgs.pkgsCross.aarch64-multiplatform.uboot {
          # defconfig = "orangepi-5-plus-rk3588_defconfig";
          defconfig = "qemu_arm64_defconfig";
          extraMakeFlags = [
            "ROCKCHIP_TPL=${rkbin-tpl.bin}"
            "BL31=${tfa.elf}"
            "TEE=${optee.elf}"
          ];

          extraConfig = ''
            CONFIG_LOG=y
            CONFIG_CMD_LOG=y
            CONFIG_LOG_DEFAULT_LEVEL=4
            CONFIG_LOG_MAX_LEVEL=7
            CONFIG_LOG_CONSOLE=y

            CONFIG_NET_LWIP=y

            CONFIG_WGET_HTTPS=y

            CONFIG_EFI_HTTP_BOOT=y

            CONFIG_CMD_GPT=y
            CONFIG_CMD_GPT_RENAME=y
            CONFIG_CMD_EFIDEBUG=y
          '';

          outputFiles = {
            bin = "u-boot.bin";
          };
        };

        uboot-tools = pkgs.pkgsCross.aarch64-multiplatform.uboot-tools;

        flash-uboot = pkgs.flash-spi-cmd {
          name = "uboot-rk3588";
          loader = rkbin-loader.bin;
          bin = uboot-rk3588.boot-spi-bin;
        };

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
            edk2Path = "./edk2";
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

        edk2-virt =
          (pkgs.pkgsCross.aarch64-multiplatform.edk2 {
            dsc = "ArmVirtPkg/ArmVirtQemu.dsc";
            buildConfig = "RELEASE";
            src = pkgs.edk2-src;
            extraBuildFlags = [ ];

            outputFiles = {
              efi-raw = "Build/ArmVirtQemu-AArch64/RELEASE_GCC/FV/QEMU_EFI-pflash.raw";
              vars-raw = "/Build/ArmVirtQemu-AArch64/RELEASE_GCC/FV/QEMU_VARS-pflash.raw";
            };
          }).overrideAttrs
            (
              final: prev: {
                preInstall = ''
                  cd $WORKSPACE/Build/ArmVirtQemu-AArch64/RELEASE_GCC/FV

                  dd of="QEMU_EFI-pflash.raw" if="/dev/zero" bs=1M count=64
                  dd of="QEMU_EFI-pflash.raw" if="QEMU_EFI.fd" conv=notrunc

                  dd of="QEMU_VARS-pflash.raw" if="/dev/zero" bs=1M count=64
                  dd of="QEMU_VARS-pflash.raw" if="QEMU_VARS.fd" conv=notrunc
                '';
              }
            );

        run-uboot = pkgs.writeScript "run-uboot" ''
          esp=$(mktemp -d)
          mkdir -p "$esp/efi/boot"
          cp ./target/aarch64-unknown-uefi/debug/httpboot.efi $esp/efi/boot/bootaa64.efi

          ${pkgs.qemu_full}/bin/qemu-system-aarch64 -M virt -cpu cortex-a76 -m 4G -nographic -serial mon:stdio \
            -bios ${uboot-virt.bin} \
            -drive format=raw,media=disk,file=fat:rw:$esp
        '';

        run-edk2 = pkgs.writeScript "run-edk2" ''
          esp=$(mktemp -d)
          mkdir -p "$esp/efi/boot"
          cp ./target/aarch64-unknown-uefi/debug/httpboot.efi $esp/efi/boot/bootaa64.efi

          ${pkgs.qemu_full}/bin/qemu-system-aarch64 -M virt -cpu cortex-a76 -m 4G -nographic \
            -drive if=pflash,format=raw,readonly=on,file=${edk2-virt.efi-raw} \
            -drive if=pflash,format=raw,snapshot=on,file=${edk2-virt.vars-raw} \
            -drive format=raw,media=disk,file=fat:rw:$esp
        '';
      };

      devShells.${system} = {
        default = pkgs.mkShell {
          packages = [
            pkgs.bear
            pkgs.qemu_full
            pkgs.pkgsCross.aarch64-multiplatform.stdenv.cc
            pkgs.rust-analyzer
            pkgs.uboot-tools
            pkgs.miniserve
            pkgs.rkdeveloptool

            (pkgs.rust-bin.stable.latest.default.override {
              extensions = [ "rust-analyzer" ];
              targets = [
                "aarch64-unknown-uefi"
                "x86_64-unknown-uefi"
              ];
            })
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
