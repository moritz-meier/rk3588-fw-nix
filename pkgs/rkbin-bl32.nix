{ runCommand, rkbin-src }:
{
  rktrust-config ? "RK3588TRUST.ini",
}:
runCommand "rkbin-bl32" { } ''
  mkdir $out

  BL32=$(grep '^PATH=.*_bl32_' ${rkbin-src}/RKTRUST/${rktrust-config} | cut -d = -f 2 -)
  BL32=${rkbin-src}/$BL32

  cp -- $BL32 $out/bl32.bin
''
