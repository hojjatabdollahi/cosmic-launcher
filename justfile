name := 'cosmic-launcher'
appid := 'com.system76.CosmicLauncher'

rootdir := ''
prefix := '/usr'
debug := '0'

appdata := appid + '.metainfo.xml'
desktop := appid + '.desktop'

base-dir := absolute_path(clean(rootdir / prefix))
cargo-target-dir := env('CARGO_TARGET_DIR', 'target')
bin-src := if debug == '1' { 'debug' / name } else { cargo-target-dir / 'release' / name }
bin-dst := base-dir / 'bin' / name
appdata-dst := base-dir / 'share' / 'appdata' / appdata
desktop-dst := base-dir / 'share' / 'applications' / desktop

export RUSTFLAGS := env_var_or_default('RUSTFLAGS', '') + ' --cfg tokio_unstable '

# Default recipe which runs `just build-release`
default: build-release

# Runs `cargo clean`
clean:
    cargo clean

# `cargo clean` and removes vendored dependencies
clean-dist: clean
    rm -rf vendor vendor.tar

# Compiles with debug profile
build-debug *args:
    cargo build {{args}}

# Compiles with release profile
build-release *args: (build-debug '--release' args)

# Compiles release profile with vendored dependencies
build-vendored *args: vendor-extract (build-release '--frozen --offline' args)

# Runs a clippy check
check *args:
    cargo clippy --all-features {{args}} -- -W clippy::pedantic

# Runs a clippy check with JSON message format
check-json: (check '--message-format=json')

# Runs after compiling a release build
run: build-release
    {{bin-src}}

# Build and run with tokio-console enabled
tokio-console: (build-release '--features console')
    env TOKIO_CONSOLE=1 {{bin-src}}

# Installs files
install:
    install -Dm0755 {{bin-src}} {{bin-dst}}
    install -Dm0644 {{ 'target' / 'xdgen' / desktop }} {{desktop-dst}}
    install -Dm0644 {{ 'target' / 'xdgen' / appdata }} {{appdata-dst}}
    @just data/icons/install

# Uninstalls installed files
uninstall:
    rm {{bin-dst}}
    @just data/uninstall
    @just data/icons/uninstall

# Vendor dependencies locally
vendor:
    cp .cargo/config.default .cargo/config.toml
    cargo vendor --locked | head -n -1 > .cargo/config.toml
    echo 'directory = "vendor"' >> .cargo/config.toml
    rm -rf vendor/winapi*gnu*/lib/*.a; \
    tar pcf vendor.tar vendor
    rm -rf vendor

# Extracts vendored dependencies
vendor-extract:
    #!/usr/bin/env sh
    rm -rf vendor
    tar pxf vendor.tar
