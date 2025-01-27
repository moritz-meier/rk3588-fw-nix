{ fetchFromGitLab, runCommand }:
{
  rktrust-config ? "RK3588TRUST.ini",
  rkbin-src ? fetchFromGitLab {
    domain = "gitlab.collabora.com";
    owner = "hardware-enablement/rockchip-3588";
    repo = "rkbin";
    rev = "master";
    hash = "sha256-KBmO++Z1AfIKvAmx7CzXScww16Stvq2BWr2raPiR6Q8=";
  },
}:
runCommand "rkbin-bl31" { } ''
  mkdir $out

  BL31=$(grep '^PATH=.*_bl31_' ${rkbin-src}/RKTRUST/${rktrust-config} | cut -d = -f 2 -)
  BL31=${rkbin-src}/$BL31

  cp -- $BL31 $out/bl31.elf
''
