{
  pkgs ? import <nixpkgs> { },
}:
pkgs.callPackage ./pkgs/kobweb-cli/package.nix { }
