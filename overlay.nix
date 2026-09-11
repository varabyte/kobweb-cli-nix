final: prev: {
  kobweb-cli-bin = final.callPackage ./pkgs/kobweb-cli-bin/package.nix { };
  kobweb-cli-src = final.callPackage ./pkgs/kobweb-cli-src/package.nix { };
}
