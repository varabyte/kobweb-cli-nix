{
  description = "Kobweb CLI's Nix package";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { ... }: {
        flake.overlays.default = import ./overlay.nix;
        systems = [
          "x86_64-linux"
          "aarch64-linux"
          "x86_64-darwin"
          "aarch64-darwin"
        ];
        perSystem = { pkgs, ... }: {
          packages = let 
            kobweb-cli = pkgs.callPackage ./pkgs/kobweb-cli/package.nix { };
          in {
            inherit kobweb-cli;
            kobweb-cli-source = pkgs.callPackage ./pkgs/kobweb-cli-source/package.nix { };
            default = kobweb-cli;
          };
        };
      }
    );
}
