final: prev: {
  rkbin-loader = prev.callPackage ./pkgs/rkbin-loader.nix { };
  rkbin-tpl = prev.callPackage ./pkgs/rkbin-tpl.nix { };
  rkbin-bl31 = prev.callPackage ./pkgs/rkbin-bl31.nix { };
  rkbin-bl32 = prev.callPackage ./pkgs/rkbin-bl32.nix { };

  trusted-firmware-a = prev.callPackage ./pkgs/trusted-firmware-a.nix { };
  optee-os = prev.callPackage ./pkgs/optee-os.nix { };

  uboot = prev.callPackage ./pkgs/uboot.nix { };
  uboot-tools = prev.callPackage ./pkgs/uboot-tools.nix { };

  # gpt-blob = prev.callPackage ./pkgs/gpt-blob.nix { };

  # uboot = prev.callPackage ./pkgs/uboot.nix { };
  # # uboot-spl-blob = prev.callPackage ./pkgs/uboot-spl-blob.nix { };

  edk2 = prev.callPackage ./pkgs/edk2.nix { };

  # edk2-rk3588-fit = prev.callPackage ./pkgs/edk2-rk3588-fit.nix { };
  # edk2-rk3588-img = prev.callPackage ./pkgs/edk2-rk3588-img.nix { };

  # flash-spi-cmd = prev.callPackage ./pkgs/flash-spi-cmd.nix { };

  rkbin-src = prev.fetchFromGitLab {
    domain = "gitlab.collabora.com";
    owner = "hardware-enablement/rockchip-3588";
    repo = "rkbin";
    rev = "master";
    hash = "sha256-gNCZwJd9pjisk6vmvtRNyGSBFfAYOADTa5Nd6Zk+qEk=";
  };

  tfa-src = final.fetchFromGitLab {
    domain = "gitlab.collabora.com";
    owner = "hardware-enablement/rockchip-3588";
    repo = "trusted-firmware-a";
    rev = "rockchip";
    hash = "sha256-vgisUSH/SEzxGQaPdWZczx8M7cgIaMmmM0BvhyzV33M=";
  };

  optee-src = final.fetchFromGitHub {
    owner = "OP-TEE";
    repo = "optee_os";
    rev = "master";
    hash = "sha256-eFUVIOWTZQuB7+iRjGXQayXx65SSimHrZ1zyZpW++bk=";
  };

  uboot-src = prev.fetchFromGitLab {
    domain = "gitlab.collabora.com";
    owner = "hardware-enablement/rockchip-3588";
    repo = "u-boot";
    rev = "rockchip";
    hash = "sha256-nNNSg/lg8MiX9rzdURkC46bw9kEjRu86nG9sjijv/nw=";
  };

  # dt-src = final.fetchgit {
  #   url = "https://git.kernel.org/pub/scm/linux/kernel/git/devicetree/devicetree-rebasing";
  #   rev = "v6.14-rc4-dts";
  #   hash = "sha256-UAYRCjR4BXKRM1vP5DW7b1xjwTdtq+EBl3qaMPIt+VA=";
  # };

  # edk2-rk3588-tfa-src = final.fetchFromGitHub {
  #   owner = "worproject";
  #   repo = "arm-trusted-firmware";
  #   rev = "rk3588";
  #   hash = "sha256-jK5X1O/W7/5iVwzxgelZhCp1Rs4GpnyPRtTEBeQYDdo=";
  # };

  edk2-rk3588-src = prev.fetchFromGitHub {
    owner = "edk2-porting";
    repo = "edk2-rk3588";
    rev = "refs/heads/master";
    hash = "sha256-Z1Klt0eQwiwkI2e6c6C+hDG7HM2/Mj+2kY8zmnsnGBg=";

    fetchSubmodules = true;
  };

  edk2-src = prev.fetchFromGitHub {
    owner = "tianocore";
    repo = "edk2";
    rev = "refs/heads/master";
    hash = "sha256-SbXcGxDjSyXfIAsXsOzSC95xFHZ+0v+C8NDd2eeCFpE=";

    fetchSubmodules = true;
  };

  # uboot-src = final.fetchFromGitLab {
  #   domain = "gitlab.collabora.com";
  #   owner = "hardware-enablement/rockchip-3588";
  #   repo = "u-boot";
  #   rev = "2025.01-rk3588";
  #   hash = "sha256-pO3Lcjlgt0wRe2r0HVRIB/KlyQiwYh4mIZ6Zc5Paut0=";
  # };
}
