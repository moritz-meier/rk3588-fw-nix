{ fetchFromGitLab, runCommand }:
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
runCommand "rkbin-tpl" { } ''
  mkdir $out

  TPL=$(grep '^FlashData' ${rkbin-src}/RKBOOT/${rkboot-config} | cut -d = -f 2 -)
  TPL=${rkbin-src}/$TPL

  cp -- $TPL $out/tpl.bin
''
