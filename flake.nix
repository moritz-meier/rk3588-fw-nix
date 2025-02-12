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
        rkbin-bl31 = pkgs.rkbin-bl31 { };
        rkbin-bl32 = pkgs.rkbin-bl32 { };

        atf = pkgs.atf { };
        optee = pkgs.optee { };

        # Prebuild uboot/mkimage blob
        # uboot = pkgs.uboot-blob {
        #   tpl = rkbin-tpl;
        # };

        # Upstream uboot/mkimage build
        uboot = pkgs.uboot {
          tpl = rkbin-tpl;
          bl31 = atf;
          defconfig = "orangepi-5-plus-rk3588_defconfig";
        };

        edk2 = pkgs.edk2 { plat = "OrangePi5Plus"; };

        boot-fit = pkgs.boot-fit {
          inherit uboot edk2;
          bl31 = atf;
          bl32 = optee;
        };

        boot-bin = pkgs.boot-bin {
          inherit uboot boot-fit;
          write-gpt-blob = true;
        };

        flash-spi-cmd = pkgs.flash-spi-cmd {
          inherit boot-bin;
          loader = rkbin-loader;
        };

        default = pkgs.buildEnv {
          name = "edk2-rk3588";

          paths = [
            rkbin-loader
            boot-bin
            boot-fit
            flash-spi-cmd
          ];
        };
      };

      devShells.${system} = {
        default = pkgs.mkShell {

          packages = with pkgs; [
            binwalk
            bison
            dtc
            flex
            gcc
            git-subrepo
            ncurses
            pkg-config
            pkgs.pkgsCross.aarch64-multiplatform.stdenv.cc.bintools
            pkgs.pkgsCross.aarch64-multiplatform.stdenv.cc.cc
            pkgs.pkgsCross.armv7l-hf-multiplatform.stdenv.cc.bintools
            pkgs.pkgsCross.armv7l-hf-multiplatform.stdenv.cc.cc
            rkdeveloptool
            ubootTools
            (python3.withPackages (
              pyPkgs: with pyPkgs; [
                cryptography
                pyelftools
              ]
            ))
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
