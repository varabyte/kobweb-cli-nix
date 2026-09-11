{
  pkgs ? import <nixpkgs> { },
}:
pkgs.callPackage ./pkgs/kobweb-cli-source/package.nix { }
