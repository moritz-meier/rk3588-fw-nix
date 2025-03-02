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
    rev = "0f8ac860f0479da56a1decae207ddc99e289f2e2";
    hash = "sha256-KBmO++Z1AfIKvAmx7CzXScww16Stvq2BWr2raPiR6Q8=";
  };

  edk2-rk3588-tfa-src = final.fetchFromGitHub {
    owner = "worproject";
    repo = "arm-trusted-firmware";
    rev = "rk3588";
    hash = "sha256-jK5X1O/W7/5iVwzxgelZhCp1Rs4GpnyPRtTEBeQYDdo=";
  };

  tfa-src = final.fetchFromGitLab {
    domain = "gitlab.collabora.com";
    owner = "hardware-enablement/rockchip-3588";
    repo = "trusted-firmware-a";
    rev = "4ec2948fe3f65dba2f19e691e702f7de2949179c";
    hash = "sha256-PCUKLfmvIBiJqVmKSUKkNig1h44+4RypZ04BvJ+HP6M=";
  };

  optee-src = builtins.fetchGit {
    url = "https://review.trustedfirmware.org/OP-TEE/optee_os";
    rev = "0919de0f7c79ad35ad3c8ace5f823ad1344b4716"; # v4.5.0
  };

  dt-src = builtins.fetchGit {
    url = "https://git.kernel.org/pub/scm/linux/kernel/git/devicetree/devicetree-rebasing";
    rev = "0b2c040bb511465806c387e9ede134caedd028c5"; # v6.14-rc4-dts
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
