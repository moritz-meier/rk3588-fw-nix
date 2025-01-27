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
runCommand "rkbin-bl32" { } ''
  mkdir $out

  BL32=$(grep '^PATH=.*_bl32_' ${rkbin-src}/RKTRUST/${rktrust-config} | cut -d = -f 2 -)
  BL32=${rkbin-src}/$BL32

  cp -- $BL32 $out/bl32.elf
''
