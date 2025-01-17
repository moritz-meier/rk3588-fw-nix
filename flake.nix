{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=release-24.11";
  };

  outputs =
    { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
      };

      pkgsAarch64 = pkgs.pkgsCross.aarch64-multiplatform;

      rkbin-src = pkgs.fetchFromGitLab {
        domain = "gitlab.collabora.com";
        owner = "hardware-enablement/rockchip-3588";
        repo = "rkbin";
        rev = "master";
        hash = "sha256-KBmO++Z1AfIKvAmx7CzXScww16Stvq2BWr2raPiR6Q8=";
      };

      linux-src = pkgs.fetchFromGitLab {
        domain = "gitlab.collabora.com";
        owner = "hardware-enablement/rockchip-3588";
        repo = "linux";
        rev = "rk3588";
        hash = "sha256-t+dtZHyIpPGd/ED/GiQTr9GMTUeBefH8cDt6KuHTmpw=";
      };

      atf-src = pkgs.fetchFromGitLab {
        domain = "gitlab.collabora.com";
        owner = "hardware-enablement/rockchip-3588";
        repo = "trusted-firmware-a";
        rev = "rk3588";
        hash = "sha256-PCUKLfmvIBiJqVmKSUKkNig1h44+4RypZ04BvJ+HP6M=";
      };

      u-boot-src = pkgs.fetchFromGitLab {
        domain = "gitlab.collabora.com";
        owner = "hardware-enablement/rockchip-3588";
        repo = "u-boot";
        rev = "rk3588";
        hash = "";
      };

      edk2-src = pkgs.fetchgit {
        url = "https://github.com/edk2-porting/edk2-rk3588.git";
        hash = "sha256-3awEMdFMGYsH18/wjQDkpMoZgWc4sfnm4ttgUof4fl4=";
        fetchSubmodules = true;
      };

      ipxe-src = pkgs.fetchFromGitHub {
        owner = "ipxe";
        repo = "ipxe";
        rev = "master";
        hash = "sha256-R6ytWBqs0ntOtlc8K4C3gXtDRBa1hf7kpWTRZz9/h4s=";
      };
    in
    {
      packages.${system} = {

        spl-loader = pkgs.runCommand "spl-loader" { nativeBuildInputs = [ ]; } ''

          cp -r -- ${rkbin-src}/ ./rkbin
          chmod -R a+rwX ./rkbin
          cd ./rkbin

          ./tools/boot_merger RKBOOT/RK3588MINIALL.ini

          mkdir $out
          cp rk3588_spl_loader_*.bin $out/
        '';

        dtbs =
          pkgs.runCommandCC "dtbs"
            {
              nativeBuildInputs = with pkgs; [
                bison
                flex
              ];
            }
            ''
              cp -r -- ${linux-src} ./linux
              chmod -R a+rwX ./linux
              cd ./linux

              make ARCH=arm64 defconfig
              make ARCH=arm64 dtbs

              mkdir $out
              pushd arch/arm64/boot/dts
              find -type f -name \*.dtb -exec install -D {} $out/dtb/{} \;
              popd
            '';

        atf = pkgsAarch64.stdenv.mkDerivation {
          name = "arm-trusted-firmware";

          src = atf-src;

          nativeBuildInputs = [
            pkgs.pkgsCross.aarch64-embedded.stdenv.cc.cc
            pkgsAarch64.binutils
          ];

          dontPatch = true;
          dontConfigure = true;

          buildPhase = ''
            export
            unset AR
            unset AS
            unset CC
            unset CXX
            unset LD
            unset NM
            unset OBJCOPY
            unset OBJDUMP
            unset RANLIB
            unset READELF
            unset SIZE
            unset STRINGS
            unset STRIP

            make CROSS_COMILE=${pkgsAarch64.stdenv.cc.targetPrefix} PLAT=rk3588 bl31
          '';

          installPhase = ''
            mkdir $out
            cp ./build/rk3588/release/bl31/bl31.elf $out/bl31.elf
          '';

          dontFixup = true;
        };

        u-boot = pkgsAarch64.ubootOrangePi5Plus.overrideAttrs (
          final: prev: {
            src = u-boot-src;

            postUnpack = ''
              rm -rd ./source/dts/upstream/src/arm64/*/
              cp -r -- ${linux-src}/arch/arm64/boot/dts/*/ ./source/dts/upstream/src/arm64/
              chmod -R a+rwX ./source/dts/upstream/src/arm64
            '';
          }
        );

        edk2 = pkgsAarch64.stdenv.mkDerivation rec {
          name = "edk2-rk3588";

          src = edk2-src;

          nativeBuildInputs = [
            pkgs.python3
            pkgs.acpica-tools
            pkgs.llvmPackages.libcxxClang
            pkgs.dtc
          ];

          buildInputs = [ pkgsAarch64.libuuid ];

          hardeningDisable = [
            "format"
            "stackprotector"
            "pic"
            "fortify"
          ];

          GCC5_AARCH64_PREFIX = pkgsAarch64.stdenv.cc.targetPrefix;

          unpackPhase = ''
            cp -r -- ${src}/ ./edk2-rk3588
            chmod -R a+rwX ./edk2-rk3588

            cd ./edk2-rk3588
          '';

          patchPhase = ''
            patchShebangs ./
          '';

          configurePhase = ''
            export WORKSPACE=$(pwd)
            export PACKAGES_PATH="$WORKSPACE/edk2:$WORKSPACE/edk2-platforms:$WORKSPACE/edk2-rockchip:$WORKSPACE/devicetree:$WORKSPACE/edk2-non-osi:$WORKSPACE"
            export PLATFORM=edk2-rockchip/Platform/OrangePi/OrangePi5Plus/OrangePi5Plus.dsc
            source edk2/edksetup.sh BaseTools
            make -C edk2/BaseTools
          '';

          buildPhase = ''
            build -a AARCH64 -b RELEASE -t GCC5 -p $PLATFORM -n $NIX_BUILD_CORES
          '';

          installPhase = ''
            mkdir $out
          '';

          dontFixup = true;
        };

        ipxe = pkgsAarch64.ipxe.overrideAttrs (final: prev: { src = ipxe-src; });
      };

      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          binwalk
          dtc
          rkdeveloptool
          git-subrepo
        ];
      };
    };
}
