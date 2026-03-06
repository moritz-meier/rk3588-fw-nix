final: prev: {
  rkbin-loader = prev.callPackage ./pkgs/rkbin-loader.nix { };
  rkbin-tpl = prev.callPackage ./pkgs/rkbin-tpl.nix { };
  rkbin-bl31 = prev.callPackage ./pkgs/rkbin-bl31.nix { };
  rkbin-bl32 = prev.callPackage ./pkgs/rkbin-bl32.nix { };

  trusted-firmware-a = prev.callPackage ./pkgs/trusted-firmware-a.nix { };

  optee-os = prev.callPackage ./pkgs/optee-os.nix { };
  optee-ftpm = prev.callPackage ./pkgs/optee-ftpm.nix { };

  uboot = prev.callPackage ./pkgs/uboot.nix { };
  uboot-tools = prev.callPackage ./pkgs/uboot-tools.nix { };

  # gpt-blob = prev.callPackage ./pkgs/gpt-blob.nix { };

  # uboot = prev.callPackage ./pkgs/uboot.nix { };
  # # uboot-spl-blob = prev.callPackage ./pkgs/uboot-spl-blob.nix { };

  edk2 = prev.callPackage ./pkgs/edk2.nix { };

  httpboot = prev.callPackage ./pkgs/httpboot.nix { };

  # edk2-rk3588-fit = prev.callPackage ./pkgs/edk2-rk3588-fit.nix { };
  # edk2-rk3588-img = prev.callPackage ./pkgs/edk2-rk3588-img.nix { };

  flash-spi-cmd = prev.callPackage ./pkgs/flash-spi-cmd.nix { };

  rkbin-src = prev.fetchFromGitLab {
    domain = "gitlab.collabora.com";
    owner = "hardware-enablement/rockchip-3588";
    repo = "rkbin";
    rev = "master";
    hash = "sha256-gNCZwJd9pjisk6vmvtRNyGSBFfAYOADTa5Nd6Zk+qEk=";
  };

  tfa-src = final.fetchgit {
    url = "https://review.trustedfirmware.org/TF-A/trusted-firmware-a";
    rev = "lts-v2.14.1";
    hash = "sha256-PLjrleN5pxl3gPH4gTTw1hxDGsmu/pmJRtDqsUZf6AE=";
  };

  optee-src = final.fetchgit {
    url = "https://review.trustedfirmware.org/OP-TEE/optee_os";
    rev = "4.9.0";
    hash = "sha256-udRTq0Rc8Ez3v9xWwk14EMZHJ7Dk0PwlWuMURLvJNyM=";
  };

  # optee-ftpm-src = final.fetchFromGitHub {
  #   owner = "OP-TEE";
  #   repo = "optee_ftpm";
  #   rev = "master";
  #   hash = "sha256-WGEpDd+yokJinTFtN7W6phUZHxBoRaJq+hvmSsY3HXU=";
  # };

  uboot-src = prev.fetchFromGitLab {
    domain = "gitlab.collabora.com";
    owner = "hardware-enablement/rockchip-3588";
    repo = "u-boot";
    rev = "rockchip";
    hash = "sha256-2401QbHm6c8mTLv4lqpCq3Ho3XY+llL7laxW3EAWkws=";
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
}
