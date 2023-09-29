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
    hash = "sha256-TeAZ8UxdvAb36PWBWFqNEoSWL8BhA9e76ccYdNPUL2A=";
    fetchSubmodules = true;
  };

  patches = [
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
  bazelTargets = [ "//pkg/cmd/cockroach-short:cockroach-short" ];

  fetchAttrs = {
    sha256 = "sha256-6HVp4t3inN0LND2Jjg9VyyESmQdK/xcDeDD+xWjA97w="; #lib.fakeHash;

    preBuild = ''
      export USER=nixbld
      rm -f .bazelversion
      rm /build/source/tools/bazel
      '';
  };

  buildAttrs = {
    preBuild = ''
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
