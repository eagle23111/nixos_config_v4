{
  description = "A dynamic island for Hyprland and niri using Quickshell";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    source.url = "https://github.com/enhaoswen/Tide-island/releases/download/1.0.35/tide-island-source.tar.xz";
    source.flake = false;
  };

  outputs = { self, nixpkgs, flake-utils, source }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        tide-island-pkg = pkgs.callPackage ./default.nix { quickshell = pkgs.quickshell; src = source; };
      in
      {
        packages.default = tide-island-pkg;

        apps.default = {
          type = "app";
          program = "${tide-island-pkg}/bin/tide-island";
        };

        devShells.default = pkgs.mkShell {
          nativeBuildInputs = [ pkgs.cmake ];
          buildInputs = with pkgs; [
            qt6.qtbase
            qt6.qtdeclarative
            qt6.qtsvg
            qt6.qtwayland
            qt6.qtconnectivity
            libudev-zero
          ];
        };
      }
    ) // {
      nixosModules.default = ./nixos;
      homeManagerModules.default = ./home-manager;
    };
}
