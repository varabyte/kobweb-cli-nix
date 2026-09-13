{
  pkgs ? import <nixpkgs> { },
}:

import ./binary.nix { inherit pkgs; }
