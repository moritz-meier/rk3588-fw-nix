final: prev: {
  rkbin-loader = final.callPackage ./pkgs/rkbin-loader.nix { };
  rkbin-tpl = final.callPackage ./pkgs/rkbin-tpl.nix { };
  rkbin-bl31 = final.callPackage ./pkgs/rkbin-bl31.nix { };
  rkbin-bl32 = final.callPackage ./pkgs/rkbin-bl32.nix { };

  atf = final.callPackage ./pkgs/atf.nix { };
  uboot = final.callPackage ./pkgs/uboot.nix { };

  edk2-base-tools = final.callPackage ./pkgs/edk2-base-tools.nix { };
  edk2 = final.callPackage ./pkgs/edk2.nix { };
}
