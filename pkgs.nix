final: prev: {
  rkbin-loader = final.callPackage ./pkgs/rkbin-loader.nix { };
  rkbin-tpl = final.callPackage ./pkgs/rkbin-tpl.nix { };
  rkbin-bl31 = final.callPackage ./pkgs/rkbin-bl31.nix { };
  rkbin-bl32 = final.callPackage ./pkgs/rkbin-bl32.nix { };

  gpt-blob = final.callPackage ./pkgs/gpt-blob.nix { };

  atf = final.callPackage ./pkgs/atf.nix { };
  optee = final.callPackage ./pkgs/optee.nix { };

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
    rev = "0f8ac860f0479da56a1decae207ddc99e289f2e2";
    hash = "sha256-KBmO++Z1AfIKvAmx7CzXScww16Stvq2BWr2raPiR6Q8=";
  };
  atf-src = builtins.fetchGit {
    url = "git@gitlab.com:moritz-meier/rk3588-trusted-firmware-a";
    rev = "0e160ebdbea4dd812ffbf2358dc09e8cf7d5675f"; # rk3588
  };
  optee-src = builtins.fetchGit {
    url = "https://review.trustedfirmware.org/OP-TEE/optee_os";
    rev = "0919de0f7c79ad35ad3c8ace5f823ad1344b4716"; # v4.5.0
  };
  dt-src = builtins.fetchGit {
    url = "https://git.kernel.org/pub/scm/linux/kernel/git/devicetree/devicetree-rebasing";
    rev = "66f0958dfb02f418625f143d7622b41b01b156e6"; # v6.13-dts
  };
  edk2-rk3588-src = builtins.fetchGit {
    url = "https://github.com/edk2-porting/edk2-rk3588";
    rev = "dbf783223f83cd0946d05f9d8cbee07bf83cbe68"; # v0.12.2
    submodules = true;
  };
  uboot-src = final.fetchFromGitLab {
    domain = "gitlab.collabora.com";
    owner = "hardware-enablement/rockchip-3588";
    repo = "u-boot";
    rev = "7293da4331c19b866883a3fc30cf8308892bf6ec"; # 2025.01-rk3588
    hash = "sha256-pO3Lcjlgt0wRe2r0HVRIB/KlyQiwYh4mIZ6Zc5Paut0=";
  };
}
