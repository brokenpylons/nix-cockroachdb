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

### The hash of the ```deps``` derivation keeps chaging

There is probably some file that contains a timestamp included in it.

### ```lifecycle-hooks``` error
```console
/build/source/pkg/ui/BUILD.bazel:5:22: Running lifecycle hooks on npm package shebang-regex@1.0.0 [for tool] failed: (Exit 1): lifecycle-hooks.sh failed: error executing command (from target //pkg/ui:.aspect_rules_js/node_modules/shebang-regex@1.0.0/lc) bazel-out/k8-opt-exec-2B5CBBC6/bin/external/aspect_rules_js/npm/private/lifecycle/lifecycle-hooks.sh shebang-regex ../../../external/npm__shebang-regex__1.0.0/package ... (remaining 1 argument skipped)
src/main/tools/process-wrapper-legacy.cc:80: "execvp(bazel-out/k8-opt-exec-2B5CBBC6/bin/external/aspect_rules_js/npm/private/lifecycle/lifecycle-hooks.sh, ...)": No such file or directory
Target //pkg/cmd/cockroach-oss:cockroach-oss failed to build
```

