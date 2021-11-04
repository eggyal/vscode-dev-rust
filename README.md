# vscode-dev-rust

A [development container](https://code.visualstudio.com/docs/remote/containers) that can be used for [VS Code Remote Development](https://code.visualstudio.com/docs/remote/remote-overview).

This container builds upon [VS Code's official Rust development container](https://github.com/microsoft/vscode-dev-containers/tree/main/containers/rust) by adding—

* The [mold](https://github.com/rui314/mold) linker (to use, invoke rustc with `-Clink-arg=-B/usr/bin/mold`; if using [Cargo](https://doc.rust-lang.org/cargo/index.html), I recommend adding this to a [`RUSTFLAGS` envvar](https://doc.rust-lang.org/cargo/reference/environment-variables.html#environment-variables-cargo-reads) via the `containerEnv` property of your [`devcontainer.json`](https://code.visualstudio.com/docs/remote/devcontainerjson-reference)).

* Various useful/popular [Cargo subcommands](https://doc.rust-lang.org/book/ch14-05-extending-cargo.html):
  * [cargo-asm](https://crates.io/crates/cargo-asm): simple viewing of the assembly or llvm-ir generated for Rust source code;
  * [cargo-edit](https://crates.io/crates/cargo-edit): addition, removal and upgrading of dependencies from the command line;
  * [cargo-expand](https://crates.io/crates/cargo-expand): shows the result of macro and `#[derive]` expansion;
  * [cargo-hack](https://crates.io/crates/cargo-hack): various options useful for testing; and
  * [cargo-tree](https://crates.io/crates/cargo-tree): visualizes a crate's dependency graph in a tree-like format.

* The [just command runner](https://crates.io/crates/just).

The built image is [available on Docker Hub](https://hub.docker.com/repository/docker/eggyal/vscode-dev-rust).

The principle motivations for defining this container separately from individual projects are to promote reuse, achieve stable/reproducible environments and maximize dev-parity with CI environments.

## Example usage

Set your project's `devcontainer.json` as follows (updating `my-project` as appropriate):

```javascript
{
  "name": "my-project-dev",
  "image": "eggyal/vscode-dev-rust:1-bullseye", // append @sha256:[digest] to pin to a specific version

  // Cargo settings to speed up compilation in development environments.
  //
  // By configuring these settings via envvars rather than Cargo configuration
  // files, the same image can be used to provide a parity toolchain in CI/CD
  // environments that use less development-oriented settings.
  "containerEnv": {
    "CARGO_PROFILE_RELEASE_DEBUG": "1",
    "CARGO_PROFILE_RELEASE_INCREMENTAL": "true",
    "CARGO_PROFILE_RELEASE_LTO": "off",
    "RUSTFLAGS": "-Clink-arg=-B/usr/bin/mold",
  },

  // A bunch of nice VS Code extensions for Rust development.
  "extensions": [
    "vadimcn.vscode-lldb",
    "matklad.rust-analyzer",
    "serayuzgur.crates",
    "tamasfe.even-better-toml",
    "yzhang.markdown-all-in-one",
    "eamodio.gitlens",
    "streetsidesoftware.code-spell-checker",
    "nhoizey.gremlins",
  ],

  // To improve disk performance on Mac OS and Windows hosts, use a named
  // volume in place of the native `target` folder.
  //
  // See https://code.visualstudio.com/remote/advancedcontainers/improve-performance#_use-a-targeted-named-volume
  "mounts": [
    "source=my-project-dev-target,target=${containerWorkspaceFolder}/target,type=volume",
  ]

  // Set permissions on mounted target volume, and trivially invoke rustc to
  // install specific toolchain required by project's toolchain file (if any).
  "postCreateCommand": "sudo chown vscode target && rustc --version",

  "remoteUser": "vscode",

  // Give container ptrace capability so that lldb can be used for debugging.
  "runArgs": [ "--init", "--cap-add=SYS_PTRACE", "--security-opt", "seccomp=unconfined" ],

  "settings": {
    "lldb.executable": "/usr/bin/lldb",
    "files.watcherExclude": {
      "target/**": true,
    },
    "rust-analyzer.checkOnSave.command": "clippy",
  },
}
```