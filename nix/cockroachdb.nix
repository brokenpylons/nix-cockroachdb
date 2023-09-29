{lib, buildBazelPackage, bazel_6, fetchFromGitHub, bash, go_1_19, gnupatch, ncurses, bison, git}:

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
  ];
  postPatch = ''
    patchShebangs .
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

  fetchAttrs = {
    sha256 = "sha256-XtIyCijwLlndQA0+BEd4dSq+bExlIX0k4r0ZW2A8bGo="; # lib.fakeHash;

    preBuild = ''
      export USER=nixbld
      rm -f .bazelversion
      rm /build/source/tools/bazel
      '';
  };

  buildAttrs = {
    preBuild = ''
      patchShebangs $bazelOut/external
      export USER=nixbld
      rm -f .bazelversion
      rm /build/source/tools/bazel
      ls c-deps/libedit
      '';

     installPhase = ''
      mkdir -p "$out/bin"
      '';
  };
}
