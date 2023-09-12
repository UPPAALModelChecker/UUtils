#!/usr/bin/env bash
#set -euxo pipefail
set -euo pipefail

if [ $# -eq 0 ] ; then
  echo "Script $0 compiles and installs dependent libraries for a set of targets specified as arguments."
  echo "Possible arguments:"
  echo "  linux64 win64 macos64"
  echo "The script is sensitive to CMake environment variables like:"
  echo "  CMAKE_TOOLCHAIN_FILE CMAKE_BUILD_TYPE CMAKE_PREFIX_PATH"
  machine=$(uname -m)
  kernel=$(uname -s)
  targets=${machine,,}-${kernel,,}
  echo "Guessing target: $targets"
else
  targets="$@"
fi

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -z "${CMAKE_BUILD_TYPE+x}" ]; then
    export CMAKE_BUILD_TYPE=Release
elif [ "$CMAKE_BUILD_TYPE" != Release ]; then
    echo "WARNING: building libs with CMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE"
fi

for target in $targets ; do
    echo "GETLIBS for $target"
    BUILD_TARGET=$target
    SOURCES="$PROJECT_DIR/local/sources"
    mkdir -p "$SOURCES"
    PREFIX="$PROJECT_DIR/local/${BUILD_TARGET}"
    # export CMAKE_PREFIX_PATH="$PREFIX"
    export CMAKE_INSTALL_PREFIX="$PREFIX"

    ## XXHASH
    NAME=xxHash
    VERSION=0.8.2
    LIBRARY="${NAME}-${VERSION}"
    ARCHIVE="$LIBRARY.tgz"
    SOURCE="${SOURCES}/$LIBRARY"
    BUILD="${PREFIX}/build-$LIBRARY"
    if [ -r "${CMAKE_INSTALL_PREFIX}/include/xxhash.h" ]; then
        echo "$LIBRARY is already installed in $CMAKE_INSTALL_PREFIX"
    else
        pushd "$SOURCES"
        if [ ! -r "${ARCHIVE}" ]; then
            wget -nv "https://github.com/Cyan4973/xxHash/archive/refs/tags/v$VERSION.tar.gz" -cO "${ARCHIVE}"
        fi
        if [ ! -d "$SOURCE" ] ; then
            tar xf "${ARCHIVE}"
        fi
        popd
        echo "Building $LIBRARY in $BUILD from $SOURCE"
        echo "  CMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE:-(unset)}"
        echo "  CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE:-(unset)}"
        echo "  CMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH:-(unset)}"
        echo "  CMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX:-(unset)}"
        cmake -S "$SOURCE/cmake_unofficial" -B "$BUILD" -DBUILD_SHARED_LIBS=OFF
        cmake --build "$BUILD" --config $CMAKE_BUILD_TYPE
        cmake --install "$BUILD" --config $CMAKE_BUILD_TYPE --prefix "${CMAKE_INSTALL_PREFIX}"
        rm -Rf "$BUILD"
        rm -Rf "$SOURCE"
    fi

    ## BOOST
    NAME=boost
    VERSION=1.83.0
    LIBRARY="${NAME}-${VERSION}"
    ARCHIVE="$LIBRARY.tar.xz"
    SOURCE="${SOURCES}/$LIBRARY"
    BUILD="${PREFIX}/build-$LIBRARY"
    if [ -r "${CMAKE_INSTALL_PREFIX}/include/boost/math/distributions/arcsine.hpp" ] ; then
        echo "$LIBRARY is already installed in $CMAKE_INSTALL_PREFIX"
    else
        pushd "$SOURCES"
        if [ ! -r "${ARCHIVE}" ]; then
            # wget "https://github.com/boostorg/boost/releases/download/$LIBRARY/$LIBRARY.tar.xz" -cO "${ARCHIVE}"
            wget -nv "https://people.cs.aau.dk/~marius/mirrors/boost/${ARCHIVE}" -cO "${ARCHIVE}"
        fi
        if [ ! -d "${SOURCE}" ]; then
            tar xf "${ARCHIVE}"
        fi
        popd
        echo "Building $LIBRARY in $BUILD from $SOURCE"
        echo "  CMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE:-(unset)}"
        echo "  CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE:-(unset)}"
        echo "  CMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH:-(unset)}"
        echo "  CMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX:-(unset)}"
        cmake -S "$SOURCE" -B "$BUILD" -DBUILD_SHARED_LIBS=OFF \
          -DBOOST_INCLUDE_LIBRARIES="headers;math" -DBOOST_ENABLE_MPI=OFF -DBOOST_ENABLE_PYTHON=OFF \
          -DBOOST_RUNTIME_LINK=static -DBUILD_TESTING=OFF -DBOOST_USE_STATIC_LIBS=ON -DBOOST_USE_DEBUG_LIBS=ON \
          -DBOOST_USE_RELEASE_LIBS=ON -DBOOST_USE_STATIC_RUNTIME=ON -DBOOST_INSTALL_LAYOUT=system -DBOOST_ENABLE_CMAKE=ON
        cmake --build "$BUILD" --config $CMAKE_BUILD_TYPE
        cmake --install "$BUILD" --config $CMAKE_BUILD_TYPE --prefix "${CMAKE_INSTALL_PREFIX}"
        rm -Rf "$BUILD"
        rm -Rf "$SOURCE"
    fi

    ## DOCTEST
    NAME=doctest
    VERSION=2.4.11
    LIBRARY="${NAME}-${VERSION}"
    ARCHIVE="$LIBRARY.tgz"
    SOURCE="${SOURCES}/$LIBRARY"
    BUILD="${PREFIX}/build-$LIBRARY"
    if [ -r "${CMAKE_INSTALL_PREFIX}/include/doctest/doctest.h" ]; then
        echo "$LIBRARY is already installed in $CMAKE_INSTALL_PREFIX"
    else
        pushd "${SOURCES}"
        if [ ! -r "${ARCHIVE}" ]; then
            wget -nv "https://github.com/doctest/doctest/archive/refs/tags/v$VERSION.tar.gz" -cO "${ARCHIVE}"
        fi
        if [ ! -d "${SOURCE}" ]; then
            tar xf "${ARCHIVE}"
        fi
        popd
        echo "Building $LIBRARY in $BUILD from $SOURCE"
        echo "  CMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE:-(unset)}"
        echo "  CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE:-(unset)}"
        echo "  CMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH:-(unset)}"
        echo "  CMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX:-(unset)}"
        cmake -S "$SOURCE" -B "$BUILD" -DDOCTEST_WITH_TESTS=OFF -DDOCTEST_WITH_MAIN_IN_STATIC_LIB=ON
        cmake --build "$BUILD" --config $CMAKE_BUILD_TYPE
        cmake --install "$BUILD" --config $CMAKE_BUILD_TYPE --prefix "${CMAKE_INSTALL_PREFIX}"
        rm -Rf "$BUILD"
        rm -Rf "$SOURCE"
    fi

    ## Google Benchmark
    NAME=benchmark
    VERSION=1.8.3 # v1.8.2 fails with "-lrt not found" on win64
    LIBRARY="${NAME}-${VERSION}"
    ARCHIVE="${LIBRARY}.tar.gz"
    SOURCE="${SOURCES}/${LIBRARY}"
    BUILD="${PREFIX}/build-${LIBRARY}"
    if [ -r "${CMAKE_INSTALL_PREFIX}/include/benchmark/benchmark.h" ] ; then
        echo "$LIBRARY is already installed in $CMAKE_INSTALL_PREFIX"
    else
        pushd "$SOURCES"
        if [ ! -r "$ARCHIVE" ]; then
            wget -nv "https://github.com/google/benchmark/archive/refs/tags/v${VERSION}.tar.gz" -cO "$ARCHIVE"
        fi
        if [ ! -d "$LIBRARY" ]; then
            tar -xf "$ARCHIVE"
        fi
        #if [ ! -d "$SOURCE" ]; then
        #   git clone -b main --no-tags --single-branch --depth 1 https://github.com/google/benchmark.git "${SOURCE}"
        #   (cd $SOURCE ; git checkout "v${VERSION}")
        #fi
        popd
        echo "Building $LIBRARY in $BUILD from $SOURCE"
        echo "  CMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE:-(unset)}"
        echo "  CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE:-(unset)}"
        echo "  CMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH:-(unset)}"
        echo "  CMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX:-(unset)}"
        cmake -S "$SOURCE" -B "$BUILD" -DBUILD_SHARED_LIBS=OFF \
          -DBENCHMARK_ENABLE_TESTING=OFF -DBENCHMARK_ENABLE_EXCEPTIONS=ON -DBENCHMARK_ENABLE_LTO=OFF \
          -DBENCHMARK_USE_LIBCXX=OFF -DBENCHMARK_ENABLE_WERROR=ON -DBENCHMARK_FORCE_WERROR=OFF
        cmake --build "$BUILD" --config $CMAKE_BUILD_TYPE
        cmake --install "$BUILD" --config $CMAKE_BUILD_TYPE --prefix "${CMAKE_INSTALL_PREFIX}"
        rm -Rf "$BUILD"
        rm -Rf "$SOURCE"
    fi
    echo "GETLIBS $target success!"
done
