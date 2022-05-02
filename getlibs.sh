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

## XXHASH
cd "$SOURCES"
if [ ! -r "xxhash-0.8.0.tgz" ]; then
  wget "https://github.com/Cyan4973/xxHash/archive/refs/tags/v0.8.0.tar.gz" -cO xxhash-0.8.0.tgz
fi
tar xf "xxhash-0.8.0.tgz"
SOURCE="$SOURCES/xxHash-0.8.0"
BUILD="$SOURCE/build"
mkdir -p "$BUILD"
cmake -S "$SOURCE/cmake_unofficial" -B "$BUILD" $CMAKE_ARGS -DCMAKE_INSTALL_PREFIX="$SOURCE_DIR/libs/xxHash" -DBUILD_SHARED_LIBS=OFF
cmake --build "$BUILD" --config Release
cmake --install "$BUILD" --config Release

## DOCTEST
cd "$SOURCES"
if [ ! -r "doctest-2.4.8.tgz" ]; then
  wget "https://github.com/doctest/doctest/archive/refs/tags/v2.4.8.tar.gz" -cO doctest-2.4.8.tgz
fi
tar xf "doctest-2.4.8.tgz"
SOURCE="$SOURCES/doctest-2.4.8"
BUILD="$SOURCE/build"
cmake -S "$SOURCE" -B "$BUILD" $CMAKE_ARGS -DCMAKE_INSTALL_PREFIX="$SOURCE_DIR/libs/doctest"
cmake --build "$BUILD" --config Release
cmake --install "$BUILD" --config Release

## BOOST
cd "$SOURCES"
if [ ! -r "boost_1_74_0.tar.bz2" ]; then
  wget "https://sourceforge.net/projects/boost/files/boost/1.74.0/boost_1_74_0.tar.bz2/download" -cO "boost_1_74_0.tar.bz2"
fi
tar xf "boost_1_74_0.tar.bz2"
mkdir -p "$SOURCE_DIR/libs/boost/include"
cp -Rp boost_1_74_0/boost "$SOURCE_DIR/libs/boost/include"
