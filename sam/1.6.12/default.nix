with import <nixpkgs> {};

let
  inputs = [ pkgs.coreutils pkgs.gcc-arm-embedded ];
in
  stdenv.mkDerivation {
    name = "arduino-due";
    version = "0.1.0.0";
    builder = "${bash}/bin/bash";
    args = [ ./build.sh ];
    buildInputs = inputs;
    src = ./.;
  }
