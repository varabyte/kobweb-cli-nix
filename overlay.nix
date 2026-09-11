final: prev: {
  kobweb-cli = final.callPackage ./pkgs/kobweb-cli/package.nix { };
  kobweb-cli-source = final.callPackage ./pkgs/kobweb-cli-source/package.nix { };
}
