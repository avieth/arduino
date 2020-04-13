{ nixpkgs ? import <nixpkgs> {} }:

with nixpkgs;

let
  sam = import ./sam/1.6.12/default.nix { inherit nixpkgs; };
  # we need a custom 1.6.1 bossa build for arduino. Other builds just don't
  # seem to work but I don't know why.
  bossa = import ./bossa/default.nix { inherit nixpkgs; };
  inputs = [
    pkgs.coreutils
    bossa
    # Compiler toolchain for the board.
    pkgs.gcc-arm-embedded
  ];
in
  stdenv.mkDerivation {
    name = "due-project";
    version = "0.1.0.0";
    builder = "${bash}/bin/bash";
    args = [ ./build.sh ];
    buildInputs = inputs;
    src = ./src;
    sam = sam;
    # To reference in the builder to create erase and upload scripts
    bossa = bossa;
    coreutils = coreutils;
    armgcc = pkgs.gcc-arm-embedded;
  }
