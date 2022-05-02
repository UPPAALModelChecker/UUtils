#!/usr/bin/env bash
set -euxo pipefail

CMAKE_ARGS="-DCMAKE_BUILD_TYPE=Release"
if [ -z ${CMAKE_TOOLCHAIN_FILE+x} ]; then
	echo "Not using a custom toolchain";
else
	echo "Using toolchain $CMAKE_TOOLCHAIN_FILE";
	CMAKE_ARGS="$CMAKE_ARGS -DCMAKE_TOOLCHAIN_FILE=$CMAKE_TOOLCHAIN_FILE";
fi

# Cursed line that should also work on macos
# https://stackoverflow.com/questions/59895/how-can-i-get-the-source-directory-of-a-bash-script-from-within-the-script-itsel
SOURCE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
SOURCES="$SOURCE_DIR/libs/sources"
mkdir -p "$SOURCES"
cd "$SOURCES"

## XXHASH
wget "https://github.com/Cyan4973/xxHash/archive/refs/tags/v0.8.0.tar.gz" -O xxhash-0.8.0.tgz
tar xf xxhash-0.8.0.tgz
SOURCE="$SOURCES/xxHash-0.8.0"
BUILD="$SOURCE/build"
mkdir -p "$BUILD"
cmake -S "$SOURCE/cmake_unofficial" -B "$BUILD" $CMAKE_ARGS -DCMAKE_INSTALL_PREFIX="$SOURCE_DIR/libs/xxHash" -DBUILD_SHARED_LIBS=OFF
cmake --build "$BUILD" --config Release
cmake --install "$BUILD" --config Release

## DOCTEST
cd "$SOURCES"
wget "https://github.com/doctest/doctest/archive/refs/tags/v2.4.8.tar.gz" -O doctest-2.4.8.tgz
tar xf doctest-2.4.8.tgz
SOURCE="$SOURCES/doctest-2.4.8"
BUILD="$SOURCE/build"
cmake -S "$SOURCE" -B "$BUILD" $CMAKE_ARGS -DCMAKE_INSTALL_PREFIX="$SOURCE_DIR/libs/doctest"
cmake --build "$BUILD" --config Release
cmake --install "$BUILD" --config Release
