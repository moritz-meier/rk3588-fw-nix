final: prev: {
  rkbin-loader = final.callPackage ./pkgs/rkbin-loader.nix { };
  rkbin-tpl = final.callPackage ./pkgs/rkbin-tpl.nix { };
  rkbin-bl31 = final.callPackage ./pkgs/rkbin-bl31.nix { };
  rkbin-bl32 = final.callPackage ./pkgs/rkbin-bl32.nix { };

  atf = final.callPackage ./pkgs/atf.nix { };
  optee = final.callPackage ./pkgs/optee.nix { };

  uboot = final.callPackage ./pkgs/uboot.nix { };
  uboot-blob = final.callPackage ./pkgs/uboot-blob.nix { };

  edk2-base-tools = final.callPackage ./pkgs/edk2-base-tools.nix { };
  edk2 = final.callPackage ./pkgs/edk2.nix { };

  boot-fit = final.callPackage ./pkgs/boot-fit.nix { };
  boot-bin = final.callPackage ./pkgs/boot-bin.nix { };

  flash-spi-cmd = final.callPackage ./pkgs/flash-spi-cmd.nix { };

  atf-src = final.fetchFromGitLab {
    domain = "gitlab.collabora.com";
    owner = "hardware-enablement/rockchip-3588";
    repo = "trusted-firmware-a";
    rev = "rk3588";
    hash = "sha256-PCUKLfmvIBiJqVmKSUKkNig1h44+4RypZ04BvJ+HP6M=";
  };
  optee-src = final.fetchFromGitHub {
    owner = "OP-TEE";
    repo = "optee_os";
    rev = "master";
    hash = "sha256-5dVpYXBvpX50LSoqTHhgkRcfL2yXbqbn7/r4rpVQntA=";
  };
  uboot-src = final.fetchFromGitLab {
    domain = "gitlab.collabora.com";
    owner = "hardware-enablement/rockchip-3588";
    repo = "u-boot";
    rev = "rk3588";
    hash = "sha256-pO3Lcjlgt0wRe2r0HVRIB/KlyQiwYh4mIZ6Zc5Paut0=";
  };
  linux-src = final.fetchFromGitLab {
    domain = "gitlab.collabora.com";
    owner = "hardware-enablement/rockchip-3588";
    repo = "linux";
    rev = "rk3588";
    hash = "sha256-t+dtZHyIpPGd/ED/GiQTr9GMTUeBefH8cDt6KuHTmpw=";
  };
  edk2-rk3588-src = final.fetchgit {
    url = "https://github.com/edk2-porting/edk2-rk3588.git";
    hash = "sha256-3awEMdFMGYsH18/wjQDkpMoZgWc4sfnm4ttgUof4fl4=";
    fetchSubmodules = true;
  };
  rkbin-src = final.fetchFromGitLab {
    domain = "gitlab.collabora.com";
    owner = "hardware-enablement/rockchip-3588";
    repo = "rkbin";
    rev = "master";
    hash = "sha256-KBmO++Z1AfIKvAmx7CzXScww16Stvq2BWr2raPiR6Q8=";
  };
}
