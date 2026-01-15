{
  writeShellScript,
  rkdeveloptool,
}:
{
  name,
  loader,
  bin,
}:
writeShellScript "${name}-flash-spi.sh" ''
  alias rkdeveloptool="${rkdeveloptool}/bin/rkdeveloptool"

  rkdeveloptool db ${loader}
  rkdeveloptool ef

  rkdeveloptool rd
  sleep 2

  rkdeveloptool db ${loader}
  rkdeveloptool wl 0 ${bin}

  rkdeveloptool rd
''
