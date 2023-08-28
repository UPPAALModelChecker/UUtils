#!/usr/bin/env bash
#set -euxo pipefail
set -euo pipefail

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
SOURCE="$SOURCES/xxHash-0.8.2"
BUILD="$SOURCE/build"
cd "$SOURCES"
if [ ! -r "xxhash-0.8.2.tgz" ]; then
  wget "https://github.com/Cyan4973/xxHash/archive/refs/tags/v0.8.2.tar.gz" -cO xxhash-0.8.2.tgz
fi
if [ ! -d "$SOURCE" ] ; then
  tar xf "xxhash-0.8.2.tgz"
fi
mkdir -p "$BUILD"
cmake -S "$SOURCE/cmake_unofficial" -B "$BUILD" $CMAKE_ARGS -DCMAKE_INSTALL_PREFIX="$SOURCE_DIR/libs" -DBUILD_SHARED_LIBS=OFF
cmake --build "$BUILD" --config Release
cmake --install "$BUILD" --config Release
rm -Rf "$SOURCE"

## DOCTEST
SOURCE="$SOURCES/doctest-2.4.11"
BUILD="$SOURCE/build"
cd "$SOURCES"
if [ ! -r "doctest-2.4.11.tgz" ]; then
  wget "https://github.com/doctest/doctest/archive/refs/tags/v2.4.11.tar.gz" -cO doctest-2.4.11.tgz
fi
if [ ! -d "${SOURCE}" ]; then
  tar xf "doctest-2.4.11.tgz"
fi
cmake -S "$SOURCE" -B "$BUILD" $CMAKE_ARGS -DCMAKE_INSTALL_PREFIX="$SOURCE_DIR/libs" -DDOCTEST_WITH_TESTS=OFF -DDOCTEST_WITH_MAIN_IN_STATIC_LIB=ON -DCMAKE_BUILD_TYPE=Release
cmake --build "$BUILD" --config Release
cmake --install "$BUILD" --config Release
rm -Rf "$SOURCE"

## BOOST
PACK="boost-1.83.0.tar.xz"
SOURCE="$SOURCES/boost-1.83.0"
BUILD="$SOURCE/build"
cd "$SOURCES"
if [ ! -r "$PACK" ]; then
#  wget "https://github.com/boostorg/boost/releases/download/{$PACK%.tar.xz}/$PACK" -cO "$PACK"
  wget "https://homes.cs.aau.dk/~marius/mirrors/boost/$PACK" -cO "$PACK"
fi
if [ ! -d "$SOURCE" ]; then
  tar xf "$PACK"
fi
mkdir -p "$BUILD"
cmake -S "$SOURCE" -B "$BUILD" $CMAKE_ARGS -DCMAKE_INSTALL_PREFIX="$SOURCE_DIR/libs" -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF -DBOOST_INCLUDE_LIBRARIES="headers;math" -DBOOST_ENABLE_MPI=OFF -DBOOST_ENABLE_PYTHON=OFF -DBOOST_RUNTIME_LINK=static -DBUILD_TESTING=OFF -DBOOST_USE_STATIC_LIBS=ON -DBOOST_USE_DEBUG_LIBS=ON -DBOOST_USE_RELEASE_LIBS=ON -DBOOST_USE_STATIC_RUNTIME=ON
cmake --build "$BUILD" --config Release
cmake --install "$BUILD" --config Release
rm -Rf "$SOURCE"

#mkdir -p "$SOURCE_DIR/libs/boost/include"
#cp -Rp boost_1_83_0/boost "$SOURCE_DIR/libs/boost/include"
