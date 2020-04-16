{ nixpkgs ? import <nixpkgs> {} 
, usb_manufacturer ? "Arduino LLC"
, usb_product ? "Arduino Due"
}:

with nixpkgs;

let
  inputs = [ pkgs.coreutils pkgs.findutils pkgs.gcc-arm-embedded ];
in
  stdenv.mkDerivation {
    name = "arduino-due";
    version = "0.1.0.0";
    builder = "${bash}/bin/bash";
    args = [ ./build.sh ];
    buildInputs = inputs;
    src = ./.;
    inherit usb_manufacturer;
    inherit usb_product;
  }
