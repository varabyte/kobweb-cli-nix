{
  description = "Kobweb CLI's Nix package";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: let
    supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
  in {
    overlays.default = import ./overlay.nix;

    packages = forAllSystems (system: let
      pkgs = import nixpkgs { inherit system; };
      bin = pkgs.callPackage ./pkgs/kobweb-cli-bin/package.nix { };
      src = pkgs.callPackage ./pkgs/kobweb-cli-src/package.nix { };
    in {
      kobweb = bin;
      kobweb-src = src;
      default = bin;
    });
  };
}
