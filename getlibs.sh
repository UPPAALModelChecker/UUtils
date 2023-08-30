#!/usr/bin/env bash
#set -euxo pipefail
set -euo pipefail

if [ $# -eq 0 ] ; then
  echo "Script $0 compiles and installs dependent libraries for a set of targets specified as arguments."
  echo "Possible arguments:"
  echo "  linux64 win64 macos64"
  echo "The script is sensitive to CMake environment variables like:"
  echo "  CMAKE_TOOLCHAIN_FILE CMAKE_BUILD_TYPE"
  exit 1
fi

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -z "${CMAKE_TOOLCHAIN_FILE+x}" ]; then
    echo "Not using a custom toolchain file."
else
    echo "Using toolchain file: $CMAKE_TOOLCHAIN_FILE"
fi

if [ -z "${CMAKE_BUILD_TYPE+x}" ]; then
    export CMAKE_BUILD_TYPE=Release
elif [ "$CMAKE_BUILD_TYPE" != Release ]; then
    echo "WARNING: building libs with CMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE"
fi

for target in "$@" ; do
    echo "GETLIBS for $target"
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
        cmake -S "$SOURCE/cmake_unofficial" -B "$BUILD" -DCMAKE_INSTALL_PREFIX="$PREFIX_DIR" -DBUILD_SHARED_LIBS=OFF
        cmake --build "$BUILD" --config $CMAKE_BUILD_TYPE
        cmake --install "$BUILD" --config $CMAKE_BUILD_TYPE
        rm -Rf "$BUILD"
    fi

    ## BOOST
    LIBRARY="boost-1.83.0"
    VERSION=${LIBRARY/[^-]*-/}
    SOURCE="$SOURCE_DIR/$LIBRARY"
    BUILD="$PREFIX_DIR/tmp/$LIBRARY"
    if [ -r "$PREFIX_DIR/include/boost/math/distributions/arcsine.hpp" ] ; then
        echo "$LIBRARY is already installed in $PREFIX_DIR"
    else
        echo "Building $LIBRARY in $BUILD from $SOURCE"
        pushd "$SOURCE_DIR"
        if [ ! -r "$LIBRARY.tar.xz" ]; then
            # wget "https://github.com/boostorg/boost/releases/download/$LIBRARY/$LIBRARY.tar.xz" -cO "$LIBRARY.tar.xz"
            wget "https://people.cs.aau.dk/~marius/mirrors/boost/$LIBRARY.tar.xz" -cO "$LIBRARY.tar.xz"
        fi
        if [ ! -d "$SOURCE" ]; then
            tar xf "$LIBRARY.tar.xz"
        fi
        popd
        mkdir -p "$BUILD"
        cmake -S "$SOURCE" -B "$BUILD" -DCMAKE_INSTALL_PREFIX="$PREFIX_DIR" -DBUILD_SHARED_LIBS=OFF \
          -DBOOST_INCLUDE_LIBRARIES="headers;math" -DBOOST_ENABLE_MPI=OFF -DBOOST_ENABLE_PYTHON=OFF \
          -DBOOST_RUNTIME_LINK=static -DBUILD_TESTING=OFF -DBOOST_USE_STATIC_LIBS=ON -DBOOST_USE_DEBUG_LIBS=ON \
          -DBOOST_USE_RELEASE_LIBS=ON -DBOOST_USE_STATIC_RUNTIME=ON -DBOOST_INSTALL_LAYOUT=system -DBOOST_ENABLE_CMAKE=ON
        cmake --build "$BUILD" --config $CMAKE_BUILD_TYPE
        cmake --install "$BUILD" --config $CMAKE_BUILD_TYPE
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
        cmake -S "$SOURCE" -B "$BUILD" -DCMAKE_INSTALL_PREFIX="$PREFIX_DIR" -DDOCTEST_WITH_TESTS=OFF -DDOCTEST_WITH_MAIN_IN_STATIC_LIB=ON
        cmake --build "$BUILD" --config $CMAKE_BUILD_TYPE
        cmake --install "$BUILD" --config $CMAKE_BUILD_TYPE
        rm -Rf "$BUILD"
    fi

    ## Google Benchmark
    LIBRARY="benchmark-db3e000c1e6675f70ae41895ca1e25b274e52554" # v1.8.2 fails with "-lrt not found" on win64
    VERSION=${LIBRARY/[^-]*-/}
    SOURCE="$SOURCE_DIR/$LIBRARY"
    BUILD="$PREFIX_DIR/tmp/$LIBRARY"
    if [ -r "$PREFIX_DIR/include/benchmark/benchmark.h" ] ; then
        echo "$LIBRARY is already installed in $PREFIX_DIR"
    else
        echo "Building $LIBRARY in $BUILD from $SOURCE"
        pushd "$SOURCE_DIR"
        #if [ ! -r "$LIBRARY.tar.gz" ]; then
        #    wget "https://github.com/google/benchmark/archive/refs/tags/v$VERSION.tar.gz" -cO "$LIBRARY.tar.gz"
        #fi
        if [ ! -d "$SOURCE" ]; then
        #    tar xf "$LIBRARY.tar.gz"
           git clone --no-tags --single-branch -b main https://github.com/google/benchmark.git $LIBRARY
           (cd $LIBRARY ; git checkout $VERSION)
        fi
        popd
        mkdir -p "$BUILD"
        cmake -S "$SOURCE" -B "$BUILD" -DCMAKE_INSTALL_PREFIX="$PREFIX_DIR" -DBUILD_SHARED_LIBS=OFF \
          -DBENCHMARK_ENABLE_TESTING=OFF -DBENCHMARK_ENABLE_EXCEPTIONS=ON -DBENCHMARK_ENABLE_LTO=OFF \
          -DBENCHMARK_USE_LIBCXX=OFF -DBENCHMARK_ENABLE_WERROR=ON -DBENCHMARK_FORCE_WERROR=OFF
        cmake --build "$BUILD" --config $CMAKE_BUILD_TYPE
        cmake --install "$BUILD" --config $CMAKE_BUILD_TYPE
        rm -Rf "$BUILD"
    fi
    echo "GETLIBS $target success!"
done
