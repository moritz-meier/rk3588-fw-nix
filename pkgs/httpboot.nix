{
  buildPackages,
  makeRustPlatform,
}:

let
  rustToolchain = buildPackages.rust-bin.stable.latest.default.override {
    targets = [ "aarch64-unknown-uefi" ];
  };

  rustPlatform = makeRustPlatform {
    cargo = rustToolchain;
    rustc = rustToolchain;
  };
in
rustPlatform.buildRustPackage {
  name = "httpboot";
  src = ../.;
  cargoLock.lockFile = ../Cargo.lock;

  buildPhase = ''
    cargo build -p httpboot --release --target=aarch64-unknown-uefi
  '';

  installPhase = ''
    mkdir -p $out/efi/boot
    cp target/aarch64-unknown-uefi/release/*.efi $out/efi/boot/bootaa64.efi
  '';
}
