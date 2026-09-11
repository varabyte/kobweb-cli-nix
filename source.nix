{
  pkgs ? import <nixpkgs> { },
}:
pkgs.callPackage ./pkgs/kobweb-cli-src/package.nix { }
