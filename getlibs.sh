#!/usr/bin/env bash
#set -euxo pipefail
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

CMAKE_ARGS="-DCMAKE_BUILD_TYPE=Release"
if [ -z "${CMAKE_TOOLCHAIN_FILE+x}" ]; then
    echo "Not using a custom toolchain file.";
else
    echo "Using toolchain file: $CMAKE_TOOLCHAIN_FILE";
    CMAKE_ARGS="$CMAKE_ARGS -DCMAKE_TOOLCHAIN_FILE=$CMAKE_TOOLCHAIN_FILE";
fi

for target in "$@" ; do
    BUILD_TARGET=$target
    SOURCE_DIR="$PROJECT_DIR/libs-sources"
    mkdir -p "$SOURCE_DIR"
    PREFIX_DIR="$PROJECT_DIR/libs-$BUILD_TARGET"

    ## XXHASH
    LIBRARY="xxHash-0.8.2"
    VERSION=${LIBRARY/[^-]*-/}
    SOURCE="$SOURCE_DIR/$LIBRARY"
    BUILD="$PREFIX_DIR/tmp/$LIBRARY"
    if [ -r "$PREFIX_DIR/include/xxhash.h" ]; then
        echo "$LIBRARY is already installed in $PREFIX_DIR"
    else
        echo "Building $LIBRARY in $BUILD from $SOURCE"
        pushd "$SOURCE_DIR"
        if [ ! -r "$LIBRARY.tgz" ]; then
            wget "https://github.com/Cyan4973/xxHash/archive/refs/tags/v$VERSION.tar.gz" -cO "$LIBRARY.tgz"
        fi
        if [ ! -d "$SOURCE" ] ; then
            tar xf "$LIBRARY.tgz"
        fi
        popd
        mkdir -p "$BUILD"
        cmake -S "$SOURCE/cmake_unofficial" -B "$BUILD" $CMAKE_ARGS -DCMAKE_INSTALL_PREFIX="$PREFIX_DIR" -DBUILD_SHARED_LIBS=OFF
        cmake --build "$BUILD" --config Release
        cmake --install "$BUILD" --config Release
        rm -Rf "$BUILD"
    fi

    ## DOCTEST
    LIBRARY="doctest-2.4.11"
    VERSION=${LIBRARY/[^-]*-/}
    SOURCE="$SOURCE_DIR/$LIBRARY"
    BUILD="$PREFIX_DIR/tmp/$LIBRARY"
    if [ -r "$PREFIX_DIR/include/doctest/doctest.h" ]; then
        echo "$LIBRARY is already installed in $PREFIX_DIR"
    else
        echo "Building $LIBRARY in $BUILD from $SOURCE"
        pushd "$SOURCE_DIR"
        if [ ! -r "$LIBRARY.tgz" ]; then
            wget "https://github.com/doctest/doctest/archive/refs/tags/v$VERSION.tar.gz" -cO "$LIBRARY.tgz"
        fi
        if [ ! -d "${SOURCE}" ]; then
            tar xf "$LIBRARY.tgz"
        fi
        popd
        cmake -S "$SOURCE" -B "$BUILD" $CMAKE_ARGS -DCMAKE_INSTALL_PREFIX="$PREFIX_DIR" -DDOCTEST_WITH_TESTS=OFF -DDOCTEST_WITH_MAIN_IN_STATIC_LIB=ON
        cmake --build "$BUILD" --config Release
        cmake --install "$BUILD" --config Release
        rm -Rf "$BUILD"
    fi

    ## BOOST
    LIBRARY="boost-1.83.0"
    VERSION=${LIBRARY/[^-]*-/}
    SOURCE="$SOURCE_DIR/$LIBRARY"
    BUILD="$PREFIX_DIR/tmp/$LIBRARY"
    if [ -r "$PREFIX_DIR/include/boost/math/distributions/arcsine.hpp" ] || [ -r "$PREFIX_DIR/include/boost-1_83/boost/math/distributions/arcsine.hpp" ] ; then
        echo "$LIBRARY is already installed in $PREFIX_DIR"
    else
        echo "Building $LIBRARY in $BUILD from $SOURCE"
        pushd "$SOURCE_DIR"
        if [ ! -r "$LIBRARY.tar.xz" ]; then
            # wget "https://github.com/boostorg/boost/releases/download/$LIBRARY/$LIBRARY.tar.xz" -cO "$LIBRARY.tar.xz"
            wget "https://homes.cs.aau.dk/~marius/mirrors/boost/$LIBRARY.tar.xz" -cO "$LIBRARY.tar.xz"
        fi
        if [ ! -d "$SOURCE" ]; then
            tar xf "$LIBRARY.tar.xz"
        fi
        mkdir -p "$BUILD"
        cmake -S "$SOURCE" -B "$BUILD" $CMAKE_ARGS -DCMAKE_INSTALL_PREFIX="$PREFIX_DIR" -DBUILD_SHARED_LIBS=OFF -DBOOST_INCLUDE_LIBRARIES="headers;math" -DBOOST_ENABLE_MPI=OFF -DBOOST_ENABLE_PYTHON=OFF -DBOOST_RUNTIME_LINK=static -DBUILD_TESTING=OFF -DBOOST_USE_STATIC_LIBS=ON -DBOOST_USE_DEBUG_LIBS=ON -DBOOST_USE_RELEASE_LIBS=ON -DBOOST_USE_STATIC_RUNTIME=ON
        cmake --build "$BUILD" --config Release
        cmake --install "$BUILD" --config Release
        rm -Rf "$BUILD"
    fi

    ## Google Benchmark
    LIBRARY="benchmark-1.7.1"
    VERSION=${LIBRARY/[^-]*-/}
    SOURCE="$SOURCE_DIR/$LIBRARY"
    BUILD="$PREFIX_DIR/tmp/$LIBRARY"
    if [ -r "$PREFIX_DIR/include/benchmark/benchmark.h" ] ; then
        echo "$LIBRARY is already installed in $PREFIX_DIR"
    else
        echo "Building $LIBRARY in $BUILD from $SOURCE"
        pushd "$SOURCE_DIR"
        if [ ! -r "$LIBRARY.tar.gz" ]; then
            wget "https://github.com/google/benchmark/archive/refs/tags/v$VERSION.tar.gz" -cO "$LIBRARY.tar.gz"
        fi
        if [ ! -d "$SOURCE" ]; then
            tar xf "$LIBRARY.tar.gz"
        fi
        mkdir -p "$BUILD"
        cmake -S "$SOURCE" -B "$BUILD" $CMAKE_ARGS -DCMAKE_INSTALL_PREFIX="$PREFIX_DIR" -DBUILD_SHARED_LIBS=OFF -DBENCHMARK_ENABLE_TESTING=OFF -DBENCHMARK_ENABLE_EXCEPTIONS=ON -DBENCHMARK_ENABLE_LTO=OFF -DBENCHMARK_USE_LIBCXX=OFF -DBENCHMARK_ENABLE_WERROR=ON -DBENCHMARK_FORCE_WERROR=OFF
        cmake --build "$BUILD" --config Release
        cmake --install "$BUILD" --config Release
        rm -Rf "$BUILD"
    fi
done
echo "Success!"
