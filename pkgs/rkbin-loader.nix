{
  fetchFromGitLab,
  runCommand,
}:

{
  rkboot-config ? "RK3588MINIALL.ini",
  rkbin-src ? fetchFromGitLab {
    domain = "gitlab.collabora.com";
    owner = "hardware-enablement/rockchip-3588";
    repo = "rkbin";
    rev = "master";
    hash = "sha256-KBmO++Z1AfIKvAmx7CzXScww16Stvq2BWr2raPiR6Q8=";
  },
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
