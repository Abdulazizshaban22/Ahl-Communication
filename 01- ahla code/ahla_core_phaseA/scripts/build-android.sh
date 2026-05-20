#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../core/ahla-core"
cargo install cargo-ndk || true
rustup target add aarch64-linux-android armv7-linux-androideabi x86_64-linux-android || true
mkdir -p ../../android/jniLibs
cargo ndk -t arm64-v8a -o ../../android/jniLibs build --release
cargo ndk -t armeabi-v7a -o ../../android/jniLibs build --release
cargo ndk -t x86_64 -o ../../android/jniLibs build --release
echo "✅ Copied to android/jniLibs/<abi>/"
