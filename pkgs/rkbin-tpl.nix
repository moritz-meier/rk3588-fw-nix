{ runCommand, rkbin-src }:
{
  rkboot-config ? "RK3588MINIALL.ini",
}:
runCommand "rkbin-tpl" { } ''
  mkdir $out

  TPL=$(grep '^FlashData' ${rkbin-src}/RKBOOT/${rkboot-config} | cut -d = -f 2 -)
  TPL=${rkbin-src}/$TPL

  cp -- $TPL $out/tpl.bin
''
