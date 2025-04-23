#!/usr/bin/env bash
#set -euxo pipefail
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

function show_help() {
    echo "Script $0 compiles and installs dependent libraries for a set of target platforms specified as arguments."
    echo "Possible arguments:"
    for toolchain_file in "$PROJECT_DIR/cmake/toolchain"/* ; do
        toolchain=$(basename $toolchain_file)
        echo "  ${toolchain%.cmake}"
    done
    echo "The script is sensitive to CMake environment variables like:"
    echo "  CMAKE_TOOLCHAIN_FILE CMAKE_BUILD_TYPE CMAKE_PREFIX_PATH"
}

if [ $# -eq 0 ] ; then
    show_help
    machine=$(uname -m)
    kernel=$(uname -s)
    targets=${machine,,}-${kernel,,}
    echo "Guessing target: $targets"
else
    case "$1" in
        -h|--help|help)
            show_help
            exit 1
            ;;
    esac
    targets="$@"
fi

if [ -z "${CMAKE_BUILD_TYPE+x}" ]; then
    export CMAKE_BUILD_TYPE=Release
elif [ "$CMAKE_BUILD_TYPE" != Release ]; then
    echo "WARNING: building libs with CMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE"
fi

if [ -n "${CMAKE_TOOLCHAIN_FILE+x}" ]; then
   TOOLCHAIN_FILE="$CMAKE_TOOLCHAIN_FILE"
fi

function show_cmake_vars() {
    for var in CMAKE_TOOLCHAIN_FILE CMAKE_BUILD_TYPE CMAKE_PREFIX_PATH CMAKE_INSTALL_PREFIX \
               CMAKE_GENERATOR CMAKE_BUILD_PARALLEL_LEVEL; do
        echo "  $var=${!var:- (unset)}"
    done
}

for target in $targets ; do
    echo "GETLIBS for $target"
    BUILD_TARGET=$target
    SOURCES="$PROJECT_DIR/local/sources"
    mkdir -p "$SOURCES"
    PREFIX="$PROJECT_DIR/local/${BUILD_TARGET}"
    # export CMAKE_PREFIX_PATH="$PREFIX"
    export CMAKE_INSTALL_PREFIX="$PREFIX"
    if [ -z "${TOOLCHAIN_FILE+x}" ] && [ -r "$PROJECT_DIR/cmake/toolchain/${target}.cmake" ] ; then
        export CMAKE_TOOLCHAIN_FILE="$PROJECT_DIR/cmake/toolchain/${target}.cmake"
    fi

    ## XXHASH
    NAME=xxHash
    VERSION=0.8.3
    LIBRARY="${NAME}-${VERSION}"
    ARCHIVE="$LIBRARY.tgz"
    SHA256=aae608dfe8213dfd05d909a57718ef82f30722c392344583d3f39050c7f29a80
    SOURCE="${SOURCES}/$LIBRARY"
    BUILD="${PREFIX}/build-$LIBRARY"
    if [ -r "${CMAKE_INSTALL_PREFIX}/include/xxhash.h" ]; then
        echo "$LIBRARY is already installed in $CMAKE_INSTALL_PREFIX"
    else
        pushd "$SOURCES"
        [ -r "${ARCHIVE}" ] || curl -sL "https://github.com/Cyan4973/xxHash/archive/refs/tags/v$VERSION.tar.gz" -o "${ARCHIVE}"
        if [ -n "$(command -v shasum)" ]; then
            echo "$SHA256  $ARCHIVE" | shasum -a256 --check -
        fi
        [ -d "$SOURCE" ] || tar xf "${ARCHIVE}"
        popd
        echo "Building $LIBRARY in $BUILD from $SOURCE"
        show_cmake_vars
        cmake -S "$SOURCE/cmake_unofficial" -B "$BUILD" -DBUILD_SHARED_LIBS=OFF
        cmake --build "$BUILD" --config $CMAKE_BUILD_TYPE
        cmake --install "$BUILD" --config $CMAKE_BUILD_TYPE --prefix "${CMAKE_INSTALL_PREFIX}"
        rm -Rf "$BUILD"
        rm -Rf "$SOURCE"
    fi

    ## BOOST
    NAME=boost
    VERSION=1.88.0
    LIBRARY="${NAME}-${VERSION}"
    ARCHIVE="${LIBRARY}-cmake.tar.xz"
    SHA256=f48b48390380cfb94a629872346e3a81370dc498896f16019ade727ab72eb1ec
    SOURCE="${SOURCES}/${LIBRARY}"
    BUILD="${PREFIX}/build-${LIBRARY}"
    if [ -r "${CMAKE_INSTALL_PREFIX}/include/boost/math/distributions/arcsine.hpp" ] ; then
        echo "$LIBRARY is already installed in $CMAKE_INSTALL_PREFIX"
    else
        pushd "$SOURCES"
        [ -r "${ARCHIVE}" ] || curl -sL "https://github.com/boostorg/boost/releases/download/${LIBRARY}/${ARCHIVE}" -o "${ARCHIVE}"
        if [ -n "$(command -v shasum)" ]; then
            echo "$SHA256  $ARCHIVE" | shasum -a256 --check -
        fi
        [ -d "${SOURCE}" ] || tar xf "${ARCHIVE}"
        popd
        echo "Building $LIBRARY in $BUILD from $SOURCE"
        show_cmake_vars
        cmake -S "$SOURCE" -B "$BUILD" -DBUILD_SHARED_LIBS=OFF \
          -DBOOST_INCLUDE_LIBRARIES="headers;math" -DBOOST_ENABLE_MPI=OFF -DBOOST_ENABLE_PYTHON=OFF \
          -DBOOST_RUNTIME_LINK=static -DBUILD_TESTING=OFF -DBOOST_INSTALL_LAYOUT=system
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
    SHA256=632ed2c05a7f53fa961381497bf8069093f0d6628c5f26286161fbd32a560186
    SOURCE="${SOURCES}/$LIBRARY"
    BUILD="${PREFIX}/build-$LIBRARY"
    if [ -r "${CMAKE_INSTALL_PREFIX}/include/doctest/doctest.h" ]; then
        echo "$LIBRARY is already installed in $CMAKE_INSTALL_PREFIX"
    else
        pushd "${SOURCES}"
        [ -r "${ARCHIVE}" ] || curl -sL "https://github.com/doctest/doctest/archive/refs/tags/v$VERSION.tar.gz" -o "${ARCHIVE}"
        if [ -n "$(command -v shasum)" ]; then
            echo "$SHA256  $ARCHIVE" | shasum -a256 --check -
        fi
        [ -d "${SOURCE}" ] || tar xf "${ARCHIVE}"
        popd
        echo "Building $LIBRARY in $BUILD from $SOURCE"
        show_cmake_vars
        cmake -S "$SOURCE" -B "$BUILD" -DDOCTEST_WITH_TESTS=OFF -DDOCTEST_WITH_MAIN_IN_STATIC_LIB=ON
        cmake --build "$BUILD" --config $CMAKE_BUILD_TYPE
        cmake --install "$BUILD" --config $CMAKE_BUILD_TYPE --prefix "${CMAKE_INSTALL_PREFIX}"
        rm -Rf "$BUILD"
        rm -Rf "$SOURCE"
    fi

    ## Google Benchmark
    NAME=benchmark
    VERSION=1.9.2 # v1.8.2 fails with "-lrt not found" on win64, v1.8.3 is good
    LIBRARY="${NAME}-${VERSION}"
    ARCHIVE="${LIBRARY}.tar.gz"
    SHA256=409075176168dc46bbb81b74c1b4b6900385b5d16bfc181d678afb060d928bd3
    SOURCE="${SOURCES}/${LIBRARY}"
    BUILD="${PREFIX}/build-${LIBRARY}"
    if [ -r "${CMAKE_INSTALL_PREFIX}/include/benchmark/benchmark.h" ] ; then
        echo "$LIBRARY is already installed in $CMAKE_INSTALL_PREFIX"
    else
        pushd "$SOURCES"
        [ -r "$ARCHIVE" ] || curl -sL "https://github.com/google/benchmark/archive/refs/tags/v${VERSION}.tar.gz" -o "$ARCHIVE"
        if [ -n "$(command -v shasum)" ]; then
            echo "$SHA256  $ARCHIVE" | shasum -a256 --check -
        fi
        [ -d "$LIBRARY" ] || tar -xf "$ARCHIVE"
        popd
        echo "Building $LIBRARY in $BUILD from $SOURCE"
        show_cmake_vars
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
