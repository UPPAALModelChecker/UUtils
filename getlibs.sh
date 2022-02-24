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
mkdir -p "$SOURCE_DIR/libs/sources";

cd $SOURCE_DIR/libs/sources;
wget https://github.com/Cyan4973/xxHash/archive/refs/tags/v0.8.0.tar.gz
tar -xvf v0.8.0.tar.gz
mkdir -p "$SOURCE_DIR/libs/sources/xxHash-0.8.0/build"
cd "$SOURCE_DIR/libs/sources/xxHash-0.8.0/build"
cmake $CMAKE_ARGS -DCMAKE_INSTALL_PREFIX="$SOURCE_DIR/libs/xxHash" -DBUILD_SHARED_LIBS=OFF ../cmake_unofficial
cmake --build . --config Release
cmake --install . --config Release
