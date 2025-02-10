{ runCommand, writeShellScript }:
{ loader, boot-bin }:

let
  flash-spi-cmd = writeShellScript "flash-spi-cmd.sh" ''
    rkdeveloptool db ${loader}/rk3588_spl_loader_v1.18.113.bin
    rkdeveloptool ef

    rkdeveloptool rd
    sleep 2

    rkdeveloptool db ${loader}/rk3588_spl_loader_v1.18.113.bin
    rkdeveloptool wl 0 ${boot-bin}/boot.bin

    rkdeveloptool rd
  '';
in
runCommand "flash-spi-cmd" { } ''
  mkdir $out
  cp ${flash-spi-cmd} $out/flash-spi.sh
''
