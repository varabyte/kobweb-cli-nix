{
  pkgs ? import <nixpkgs> { },
}:
pkgs.callPackage ./pkgs/kobweb-cli-bin/package.nix { }
