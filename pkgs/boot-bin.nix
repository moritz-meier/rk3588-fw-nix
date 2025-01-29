{ fetchgit, runCommand }:
{
  uboot,
  boot-fit,
  edk2-rk3588-src ? fetchgit {
    url = "https://github.com/edk2-porting/edk2-rk3588.git";
    hash = "sha256-3awEMdFMGYsH18/wjQDkpMoZgWc4sfnm4ttgUof4fl4=";
    fetchSubmodules = true;
  },
}:

runCommand "boot-bin" { } ''
  mkdir $out

  dd if=${edk2-rk3588-src}/misc/rk3588_spi_nor_gpt.img of=$out/boot.bin
  dd if=${uboot}/idbloader.img of=$out/boot.bin bs=1K seek=32
  dd if=${boot-fit}/rk3588-uefi.fit of=$out/boot.bin bs=1K seek=1024
''
