# Nix derivation for Cockroachdb

An attempt to build CockroachDB using bazel.
The derivation is based on ```buildBazelPackage```. 
Currently the ```//pkg/cmd/cockroach-short:cockroach-short``` target is used, which is not the full build, however I can't even get that to work.

The build instructions are [here](https://cockroachlabs.atlassian.net/wiki/spaces/CRDB/pages/2221703221/Developing+with+Bazel).

## Open issues

### ```grpc_gateway``` patch cannot be applied

This [patch](https://github.com/cockroachdb/cockroach/blob/v23.1.10/build/patches/com_github_grpc_ecosystem_grpc_gateway.patch) cannot be applied.
I solved this by [forking the orignal repo](https://github.com/brokenpylons/grpc-gateway), appling the patch manually and then replacing the dependecy with my repository.
Obviously, this is not an ideal solution, there should be a way to apply the patch, however I can't figure it out.

### ```libedit``` files not picked up

The [cockroach-libedit](https://github.com/cockroachdb/libedit) files with are included as a submodule are not picked up by bazel.
```console
com_github_cockroachdb_cockroach/external/com_github_knz_go_libedit/unix/editline_unix.go:40:11: fatal error: histedit.h: No such file or directory
```
This is not worth solving, since ```libedit``` is going to be removed in the next version.

## Alpha version (not included in this repo)

Using the alpha version almost works, however it fails with:
```console
Use --sandbox_debug to see verbose messages from the sandbox and retain the sandbox build root for debugging
link: package conflict error: go.opentelemetry.io/proto/otlp/collector/trace/v1: package imports github.com/golang/protobuf/descriptor
          was compiled with: @com_github_golang_protobuf//descriptor:go_default_library_gen
        but was linked with: @com_github_golang_protobuf//descriptor:descriptor
```
This might get fixed when the next version is released.
