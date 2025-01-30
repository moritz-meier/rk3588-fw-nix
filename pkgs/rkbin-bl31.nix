{ runCommand, rkbin-src }:
{
  rktrust-config ? "RK3588TRUST.ini",
}:
runCommand "rkbin-bl31" { } ''
  mkdir $out

  BL31=$(grep '^PATH=.*_bl31_' ${rkbin-src}/RKTRUST/${rktrust-config} | cut -d = -f 2 -)
  BL31=${rkbin-src}/$BL31

  cp -- $BL31 $out/bl31.elf
''
