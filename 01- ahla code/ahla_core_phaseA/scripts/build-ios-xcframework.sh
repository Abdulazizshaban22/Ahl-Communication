#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../core/ahla-core"
rustup target add aarch64-apple-ios aarch64-apple-ios-sim || true
cargo build --release --target aarch64-apple-ios
cargo build --release --target aarch64-apple-ios-sim
cargo install cbindgen || true
cbindgen --config cbindgen.toml --crate ahla-core --output ../../include/ahla_core.h
IOS_DEV=target/aarch64-apple-ios/release/libahla_core.a
IOS_SIM=target/aarch64-apple-ios-sim/release/libahla_core.a
mkdir -p ../../dist
xcodebuild -create-xcframework -library "$IOS_DEV" -headers ../../include \
  -library "$IOS_SIM" -headers ../../include \
  -output ../../dist/AhlaCore.xcframework
echo "✅ XCFramework ready at dist/AhlaCore.xcframework"
