{ runCommand, edk2-rk3588-src }:
{
  uboot,
  boot-fit,
}:

runCommand "boot-bin" { } ''
  mkdir $out

  # dd if=${edk2-rk3588-src}/misc/rk3588_spi_nor_gpt.img of=$out/boot.bin
  dd if=${uboot}/idbloader.img of=$out/boot.bin bs=1K seek=32
  dd if=${boot-fit}/rk3588-uefi.fit of=$out/boot.bin bs=1K seek=1024
''
