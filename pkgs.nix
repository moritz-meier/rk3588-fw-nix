final: prev: {
  rkbin-loader = final.callPackage ./pkgs/rkbin-loader.nix { };
  rkbin-tpl = final.callPackage ./pkgs/rkbin-tpl.nix { };
  rkbin-bl31 = final.callPackage ./pkgs/rkbin-bl31.nix { };
  rkbin-bl32 = final.callPackage ./pkgs/rkbin-bl32.nix { };

  gpt-blob = final.callPackage ./pkgs/gpt-blob.nix { };

  trusted-firmware-a = final.callPackage ./pkgs/trusted-firmware-a.nix { };
  optee-os = final.callPackage ./pkgs/optee-os.nix { };

  uboot = final.callPackage ./pkgs/uboot.nix { };
  uboot-spl-blob = final.callPackage ./pkgs/uboot-spl-blob.nix { };

  edk2-base-tools = final.callPackage ./pkgs/edk2-base-tools.nix { };
  edk2-rk3588 = final.callPackage ./pkgs/edk2-rk3588.nix { };

  edk2-rk3588-fit = final.callPackage ./pkgs/edk2-rk3588-fit.nix { };
  edk2-rk3588-img = final.callPackage ./pkgs/edk2-rk3588-img.nix { };

  flash-spi-cmd = final.callPackage ./pkgs/flash-spi-cmd.nix { };

  rkbin-src = final.fetchFromGitHub {
    owner = "rockchip-linux";
    repo = "rkbin";
    rev = "master";
    hash = "sha256-KBmO++Z1AfIKvAmx7CzXScww16Stvq2BWr2raPiR6Q8=";
  };

  tfa-src = final.fetchFromGitLab {
    domain = "gitlab.collabora.com";
    owner = "hardware-enablement/rockchip-3588";
    repo = "trusted-firmware-a";
    rev = "rk3588";
    hash = "sha256-PCUKLfmvIBiJqVmKSUKkNig1h44+4RypZ04BvJ+HP6M=";
  };

  optee-src = final.fetchgit {
    url = "https://review.trustedfirmware.org/OP-TEE/optee_os";
    rev = "4.5.0";
    hash = "sha256-o79+TYx1WleqYnr2uMiK2/jOt2aS2s+2uDKFKJa4ZIg=";
  };

  dt-src = final.fetchgit {
    url = "https://git.kernel.org/pub/scm/linux/kernel/git/devicetree/devicetree-rebasing";
    rev = "v6.14-rc4-dts";
    hash = "sha256-UAYRCjR4BXKRM1vP5DW7b1xjwTdtq+EBl3qaMPIt+VA=";
  };

  edk2-rk3588-tfa-src = final.fetchFromGitHub {
    owner = "worproject";
    repo = "arm-trusted-firmware";
    rev = "rk3588";
    hash = "sha256-jK5X1O/W7/5iVwzxgelZhCp1Rs4GpnyPRtTEBeQYDdo=";
  };

  edk2-rk3588-src = final.fetchgit {
    url = "https://github.com/edk2-porting/edk2-rk3588";
    rev = "v0.12.2";
    fetchSubmodules = true;
    hash = "sha256-ny7XgxnHJ/AK6n1HHeVe8ammgDhhOv/R7AZXTWLPn6M=";
  };

  uboot-src = final.fetchFromGitLab {
    domain = "gitlab.collabora.com";
    owner = "hardware-enablement/rockchip-3588";
    repo = "u-boot";
    rev = "2025.01-rk3588";
    hash = "sha256-pO3Lcjlgt0wRe2r0HVRIB/KlyQiwYh4mIZ6Zc5Paut0=";
  };
}
