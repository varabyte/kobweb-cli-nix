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
      kobweb-cli-bin = pkgs.callPackage ./pkgs/kobweb-cli-bin/package.nix { };
      kobweb-cli-src = pkgs.callPackage ./pkgs/kobweb-cli-src/package.nix { };
    in {
      inherit kobweb-cli-bin kobweb-cli-src;
      default = kobweb-cli-bin;
    });
  };
}
