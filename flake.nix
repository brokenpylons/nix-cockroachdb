{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs;
    flake-utils.url = github:numtide/flake-utils;
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      lib = nixpkgs.lib;
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      cockroachdb = pkgs.callPackage ./nix/cockroachdb.nix {};
    in
    {
      packages.cockroachdb-deps = cockroachdb.deps;
      packages.cockroachdb = cockroachdb;
    });
}


