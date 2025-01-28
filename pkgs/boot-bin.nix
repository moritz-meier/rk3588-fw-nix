{ runCommand }:
{ uboot }:

runCommand "boot-bin" { } ''
  mkdir $out

  dd if=${uboot}/idbloader.img of=$out/boot.bin bs=1K seek=32
''
