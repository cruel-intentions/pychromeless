{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/";
    flake-utils.url = "github:numtide/flake-utils";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
  };
  outputs = { self, nixpkgs, flake-utils, pre-commit-hooks }:
    let
      utils = flake-utils.lib;
      mkFlake = pkgs: system:
        rec {
          checks = import ./nix/check.nix {
            pre-commit-hooks = with pre-commit-hooks; lib.${system} or lib.aarch64-linux;
          };
          devShell = pkgs.mkShell {
            shellHook = self.checks.${system}.pre-commit-check.shellHook;
          };
          packages.pychromeless = import ./package.nix { inherit pkgs; };
          defaultPackage = packages.pychromeless;
        };
    in
    utils.eachDefaultSystem (system: mkFlake nixpkgs.legacyPackages.${system} system);
}
