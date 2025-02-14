{ runCommand, writeShellScript }:
{
  loader,
  bin,
}:

let
  flash-spi-cmd = writeShellScript "flash-spi-cmd.sh" ''
    rkdeveloptool db ${loader}
    rkdeveloptool ef

    rkdeveloptool rd
    sleep 2

    rkdeveloptool db ${loader}
    rkdeveloptool wl 0 ${bin}

    rkdeveloptool rd
  '';
in
runCommand "flash-spi-cmd" { } ''
  mkdir $out
  cp ${flash-spi-cmd} $out/flash-spi.sh
''
