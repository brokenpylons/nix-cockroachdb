{lib, buildBazelPackage, bazel_6, fetchFromGitHub, bash, go_1_19, gnupatch, ncurses, bison, git, writeText, nodejs_16}:

let
  rev = "6bd6e0c65a2eba531e7a8412d63988abb5b50120";
in
buildBazelPackage {
  pname = "cockroachdb";
  version = "23.1.10";
  bazel = bazel_6;

  src = fetchFromGitHub {
    owner = "cockroachdb";
    repo = "cockroach";
    inherit rev;
    hash = "sha256-AeaYBe9+Og7U16Akm2OJGhWA5hBM3D7Ld/uU7QZd7Nw=";
    fetchSubmodules = true;
  };

  patches = [
    ./remove_libedit.patch
    ./add_remove_exists.patch
    ./use_local_go.patch
    ./patch_tool.patch
    ./node.patch
  ];
  postPatch = ''
    patchShebangs .
    substituteInPlace build/toolchains/BUILD.bazel \
      --subst-var-by nodejs ${nodejs_16}
    cp ${./remove_exists.patch} remove_exists.patch
  '';

  nativeBuildInputs = [
    bash
    go_1_19
    gnupatch
    ncurses
    bison
    git
  ];

  removeRulesCC = false;
  bazelTargets = [ "//pkg/cmd/cockroach-oss" ];
  bazelBuildFlags = [
    "--jobs 1"
    "--verbose_failures"
    "--subcommands"
    "--keep_going"
    "--spawn_strategy=standalone"
  ];

  fetchAttrs = {
    sha256 = "sha256-V8BtTkuHzQoZfqmL5zPy/rQRwYFb+t3/QY4wjdc8xbc="; # lib.fakeHash;

    preBuild = ''
      export USER=nixbld
      rm -f .bazelversion
      rm /build/source/tools/bazel
    '';

     preInstall = ''
       rm -rf $bazelOut/external/bazel_gazelle_go_repository_cache/gocache
     '';
  };

  buildAttrs = {
    preBuild = ''
      #patchShebangs $bazelOut/external
      export USER=nixbld
      rm -f .bazelversion
      rm /build/source/tools/bazel
      #sed -i -e 's:#!/usr/bin/env bash:#!/${bash}/bin/bash:' $bazelOut/external/aspect_rules_js/npm/private/lifecycle/lifecycle-hooks.js

      chmod +x $bazelOut/external/aspect_rules_js/js/private/js_binary.sh.tpl
      patchShebangs $bazelOut/external/aspect_rules_js/
    '';

    installPhase = ''
      mkdir -p "$out/bin"
  '';
  };
}
