{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=release-24.11";

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
        # rkbin-bl31 = pkgs.rkbin-bl31 { };
        # rkbin-bl32 = pkgs.rkbin-bl32 { };

        foo = pkgs.edk2-rk3588-src;

        edk2-rk3588 = rec {
          gpt-blob = pkgs.gpt-blob { };

          uboot-spl-blob = pkgs.uboot-spl-blob {
            tpl = rkbin-tpl.bin;
          };

          tfa = (pkgs.trusted-firmware-a.override { tfa-src = pkgs.edk2-rk3588-tfa-src; }) {
            plat = "rk3588_reference_pmic";
          };
          optee = pkgs.optee-os { };

          edk2-base-tools = pkgs.edk2-base-tools;

          edk2 = pkgs.edk2-rk3588 {
            plat = "OrangePi5Plus";
            # dt-src = pkgs.dt-src;
          };

          fit = pkgs.edk2-rk3588-fit {
            bl31 = tfa.elf;
            bl32 = optee.bin;
            bl33 = edk2.fw;
            dtb = uboot-spl-blob.spl.dtb;
            mkimage = uboot-spl-blob;
          };

          img = pkgs.edk2-rk3588-img {
            gpt = gpt-blob.bin;
            idbloader = uboot-spl-blob.idbloader.bin;
            fit = fit.fit;
          };

          flash-spi-cmd = pkgs.flash-spi-cmd {
            name = "edk2-rk3588";
            loader = rkbin-loader.bin;
            bin = img.bin;
          };
        };

        uboot-rk3588 = rec {
          tfa = pkgs.trusted-firmware-a { };
          optee = pkgs.optee-os { };

          uboot = pkgs.uboot {
            defconfig = "orangepi-5-plus-rk3588_defconfig";
            tpl = rkbin-tpl.bin;
            bl31 = tfa.elf;
            bl32 = optee.elf;
            dt-src = pkgs.dt-src;
          };

          flash-spi-cmd = pkgs.flash-spi-cmd {
            name = "uboot-rk3588";
            loader = rkbin-loader.bin;
            bin = uboot.boot-spi.bin;
          };
        };
      };

      devShells.${system} = {
        default = pkgs.mkShell {

          packages = with pkgs; [
            binwalk
            dtc
            rkdeveloptool
            openssl
            pkg-config
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
