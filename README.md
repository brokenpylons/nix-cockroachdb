# Nix derivation for CockroachDB

An attempt to build CockroachDB using ```bazel```.
The derivation is based on ```buildBazelPackage```. 
Currently the ```//pkg/cmd/cockroach-oss``` target is used.
The ```//pkg/cmd/cockroach-short``` target fails with the ```opentelemetry``` linking error.

The build instructions are [here](https://cockroachlabs.atlassian.net/wiki/spaces/CRDB/pages/2221703221/Developing+with+Bazel).

## Solved

### ```libedit``` files not picked up

The [cockroach-libedit](https://github.com/cockroachdb/libedit) files which are included as a submodule are not picked up by ```bazel```.
```console
com_github_cockroachdb_cockroach/external/com_github_knz_go_libedit/unix/editline_unix.go:40:11: fatal error: histedit.h: No such file or directory
```
This is not worth solving, since ```libedit``` is going to be removed in the next version.

By some miracle libedit can be removed cleanly by cherry picking [commit](https://github.com/cockroachdb/cockroach/pull/105282/commits/1d39c48e32bb5847fcca363b8518b6db87485bf7).

### The hash of the ```deps``` derivation keeps chaging

There is probably some file that contains a timestamp included in it.

There are time stamps in ```/external/bazel_gazelle_go_repository_cache/gocache```, removed.

### ```lifecycle-hooks``` error
```console
/build/source/pkg/ui/BUILD.bazel:5:22: Running lifecycle hooks on npm package shebang-regex@1.0.0 [for tool] failed: (Exit 1): lifecycle-hooks.sh failed: error executing command (from target //pkg/ui:.aspect_rules_js/node_modules/shebang-regex@1.0.0/lc) bazel-out/k8-opt-exec-2B5CBBC6/bin/external/aspect_rules_js/npm/private/lifecycle/lifecycle-hooks.sh shebang-regex ../../../external/npm__shebang-regex__1.0.0/package ... (remaining 1 argument skipped)
src/main/tools/process-wrapper-legacy.cc:80: "execvp(bazel-out/k8-opt-exec-2B5CBBC6/bin/external/aspect_rules_js/npm/private/lifecycle/lifecycle-hooks.sh, ...)": No such file or directory
Target //pkg/cmd/cockroach-oss:cockroach-oss failed to build
```
The soluton was to patch shabangs in rules_js and use a local version of node.

## Hacks

### ```grpc_gateway``` patch cannot be applied

This [patch](https://github.com/cockroachdb/cockroach/blob/v23.1.10/build/patches/com_github_grpc_ecosystem_grpc_gateway.patch) cannot be applied.
I solved this by [forking the orignal repo](https://github.com/brokenpylons/grpc-gateway), appling the patch manually and then replacing the dependecy with my repository.
Obviously, this is not an ideal solution, there should be a way to apply the patch, however, I can't figure it out.

## Open issues

### ```opentelemetry``` linking error
```console
error: builder for '/nix/store/9wnyqx3amb14ybh3d9grrcn6w95dy3yg-cockroachdb-23.1.10.drv' failed with exit code 1;
       last 10 log lines:
       > link: package conflict error: go.opentelemetry.io/proto/otlp/collector/trace/v1: package imports github.com/golang/protobuf/descriptor
       > 	  was compiled with: @com_github_golang_protobuf//descriptor:go_default_library_gen
       > 	but was linked with: @com_github_golang_protobuf//descriptor:descriptor
       > See https://github.com/bazelbuild/rules_go/issues/1877.
       > Target //pkg/cmd/cockroach-short:cockroach-short failed to build
```
Possibly solved by doing an OSS build, which doesn't include CCL pacakges, one of which includes ```opentelemetry```.

### ```webpack``` error

```console
ERROR: /build/source/pkg/ui/workspaces/cluster-ui/BUILD.bazel:38:24: WebpackCli pkg/ui/workspaces/cluster-ui/dist/js/main.js failed: (Exit 1): webpack__js_binary.sh failed: error executing command (from target //pkg/ui/workspaces/cluster-ui:webpack)
  (cd /build/output/execroot/com_github_cockroachdb_cockroach && \
  exec env - \
    BAZEL_BINDIR=bazel-out/k8-fastbuild/bin \
    BAZEL_BUILD_FILE_PATH=pkg/ui/workspaces/cluster-ui/BUILD.bazel \
    BAZEL_COMPILATION_MODE=fastbuild \
    BAZEL_PACKAGE=pkg/ui/workspaces/cluster-ui \
    BAZEL_TARGET=//pkg/ui/workspaces/cluster-ui:webpack \
    BAZEL_TARGET_CPU=k8 \
    BAZEL_TARGET_NAME=webpack \
    BAZEL_WORKSPACE=com_github_cockroachdb_cockroach \
    JS_BINARY__CHDIR=pkg/ui/workspaces/cluster-ui \
    JS_BINARY__PATCH_NODE_FS=1 \
    JS_BINARY__SILENT_ON_SUCCESS=1 \
    JS_BINARY__USE_EXECROOT_ENTRY_POINT=1 \
    PATH=/nix/store/xdqlrixlspkks50m9b0mpvag65m3pf2w-bash-5.2-p15/bin:/nix/store/y9gr7abwxvzcpg5g73vhnx1fpssr5frr-coreutils-9.3/bin:/nix/store/q56n7lhjw724i7b33qaqra61p7m7c0cd-diffutils-3.10/bin:/nix/store/3ssn79pr531nfyh578r9kwvinp0mvy72-file-5.45/bin:/nix/store/b6izr8wh0p7dyvh3cyg14wq2rn8d31ik-findutils-4.9.0/bin:/nix/store/8kkn44iwdbgqkrj661nr4cjcpmrqqmx8-gawk-5.2.2/bin:/nix/store/xafzciap7acqhfx84dvqkp18bg4lrai3-gnugrep-3.11/bin:/nix/store/c15ama0p8jr4mn0943yjk4rpa2hxk7ml-patch-2.7.6/bin:/nix/store/x23by79p38ll0js1alifmf3y56vqfs49-gnused-4.9/bin:/nix/store/89s3w7b4g78989kpzc7sy4phv0nqfira-gnutar-1.35/bin:/nix/store/2a9na7bp4r3290yqqzg503325dwglxyq-gzip-1.13/bin:/nix/store/pzf6dnxg8gf04xazzjdwarm7s03cbrgz-python3-3.10.12/bin:/nix/store/hjspq68ljkw2pxlki8mh6shi32s67m89-unzip-6.0/bin:/nix/store/9n0384r446blhgla21fpvyr0qnjgjwaw-which-2.21/bin:/nix/store/r77zgzm8a4086678daxvwja7ivcz1d7l-zip-3.0/bin \
  bazel-out/k8-opt-exec-2B5CBBC6/bin/pkg/ui/workspaces/cluster-ui/webpack__js_binary.sh ./src/index.ts --config webpack.config.js --env.is_bazel_build --mode production -o ./dist/js/main.js '--env.output=./dist/js/main.js')
# Configuration: af862557808549cfaad26ca3c984113dac8aab15b5849239f499548c512f2e84
# Execution platform: @local_config_platform//:host
/build/output/execroot/com_github_cockroachdb_cockroach/bazel-out/k8-fastbuild/bin/pkg/ui/node_modules/.aspect_rules_js/loader-runner@2.4.0/node_modules/loader-runner/lib/LoaderRunner.js:106
                        throw new Error("callback(): The callback was already called.");
                              ^

Error: callback(): The callback was already called.
    at context.callback (/build/output/execroot/com_github_cockroachdb_cockroach/bazel-out/k8-fastbuild/bin/pkg/ui/node_modules/.aspect_rules_js/loader-runner@2.4.0/node_modules/loader-runner/lib/LoaderRunner.js:106:10)
    at Object.ESBuildLoader (/build/output/execroot/com_github_cockroachdb_cockroach/bazel-out/k8-fastbuild/bin/pkg/ui/node_modules/.aspect_rules_js/esbuild-loader@2.19.0_webpack_4.41.5/node_modules/esbuild-loader/dist/loader.js:62:9)
    at processTicksAndRejections (node:internal/process/task_queues:96:5)
ℹ Compiling Cluster-ui
```

Other targets that use webpack succeed, so I'm not sure what is the cause.

Problems like this seem to be endemic to this project, where all but one target succeeds.
