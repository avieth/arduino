{ nixpkgs ? import <nixpkgs> {} }:
with nixpkgs;
stdenv.mkDerivation {
  name = "bossa";
  version = "1.6.1";
  src = ./.;
  buildInputs = [
    coreutils gcc automake gnumake readline wxGTK30 x11 gnused gnugrep
  ];
  builder = "${pkgs.bash}/bin/bash";
  args = [ ./build.sh ];
}
