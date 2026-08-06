{
  description = "Nix flake for the Manatan immersion software";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    systems = [
      "x86_64-linux"
      "aarch64-linux"
    ];

    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    packages = forAllSystems (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        default = pkgs.callPackage ./manatan.nix {};
      }
    );

    apps = forAllSystems (
      system: {
        default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/manatan";
        };
      }
    );
  };
}
