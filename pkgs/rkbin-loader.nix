{
  runCommand,
  rkbin-src,
}:

{
  rkboot-config ? "RK3588MINIALL.ini",
}:

runCommand "rkbin-loader" { } ''

  cp -r -- ${rkbin-src}/ ./source
  chmod -R a+rwX ./source
  cd ./source

  ./tools/boot_merger RKBOOT/${rkboot-config}

  loader=$(grep '^PATH=.*_loader_.*\.bin' ${rkbin-src}/RKBOOT/${rkboot-config} | cut -d = -f 2 -)

  mkdir $out
  cp -- $loader $out/
''
