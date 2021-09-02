{ pkgs }:
let
  src = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/NixOS/nixpkgs/nixos-21.05/pkgs/development/libraries/nss/default.nix";
    sha256 = "sha256-+057E/eEsvZNAozezZjrJxLZGlzY1d3ydwguJY+0oh4=";
  };
  secPatch = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/NixOS/nixpkgs/nixos-21.05/pkgs/development/libraries/nss/85_security_load.patch";
    sha256 = "sha256-gei271JvrDKperm23zKCr/+3sg2y/+FmEFzSkZaMBQI=";
  };
  ckpemPatch = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/NixOS/nixpkgs/nixos-21.05/pkgs/development/libraries/nss/ckpem.patch";
    sha256 = "sha256-pDyOIJmvGrXbjI/NJNQzwDh0dwkxrRTymptDnDTfANE=";
  };
  fixCrossCompPatch = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/NixOS/nixpkgs/nixos-21.05/pkgs/development/libraries/nss/fix-cross-compilation.patch";
    sha256 = "sha256-bhISIUw79NaH6opO+ANHCFV3x+wi82grmK3ALbFQFho=";
  };
in
pkgs.stdenv.mkDerivation {
  name = "nssNixPatch";
  src = ./.;
  installPhase = ''
    mkdir $out
    sed "s,PREFIX/lib64,PREFIX/lib,"  ${src} > $out/default.nix
    cp ${secPatch} $out/85_security_load.patch
    cp ${ckpemPatch} $out/ckpem.patch
    cp ${fixCrossCompPatch} $out/fix-cross-compilation.patch
  '';
}
