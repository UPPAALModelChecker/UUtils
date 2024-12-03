#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

function show_toolchains() {
    for toolchain_file in "$PROJECT_DIR/cmake/toolchain"/* ; do
        toolchain=$(basename $toolchain_file)
        echo "  ${toolchain%.cmake}"
    done
}

function show_help() {
    echo "Script $0 compiles this library for a set of target platforms specified as arguments."
    echo "Possible targets:"
    show_toolchains
    echo "Possible target suffixes (append to the target making one word):"
    echo "  -ubsan - build with undefined behavior sanitizer (may break benchmarks with g++-13)"
    echo "  -lsan - build with memory leak sanitizer (expect test_new to fail as it leaks on purpose)"
    echo "  -asan - build with address sanitizer (expect test_new to fail as it leaks on purpose)"
    echo "  -debug/-release - build either with debug information or optimized for release"
    echo "For example, build linux64 release with undefined behavior sanitizer:"
    echo "  $0 x64_86-linux-ubsan-release"
    echo "The script is sensitive to CMAKE_BUILD_TYPE and other environment variables"
}

if [ $# -eq 0 ] ; then
    show_help
    machine=$(uname -m)
    kernel=$(uname -s)
    targets="${machine,,}-${kernel,,}-release"
    if [ -n "$(command -v x86_64-w64-mingw32-g++)" ]; then
        targets="$targets x86_64-w64-mingw32-release"
    fi
    echo "Guessing: $targets"
else
    case "$1" in
        -h|--help|help)
            show_help
            exit 1
            ;;
    esac
    targets="$@"
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
    unset CMAKE_PREFIX_PATH
    unset CMAKE_BUILD_TYPE
    unset BUILD_TARGET
    BUILD_SUFFIX=""
    BUILD_EXTRA=""
    case "$target" in
        x86_64-linux-gcc10*)
            BUILD_TARGET=x86_64-linux-gcc10
            ;;
        x86_64-linux*)
            BUILD_TARGET=x86_64-linux
            ;;
        i686-linux-gcc10*)
            BUILD_TARGET=i686-linux-gcc10
            ;;
        i686-linux*)
            BUILD_TARGET=i686-linux
            ;;
        x86_64-w64-mingw32*)
            BUILD_TARGET=x86_64-w64-mingw32
            export WINEPATH=$("$PROJECT_DIR"/winepath-for $BUILD_TARGET)
            ;;
        i686-w64-mingw32*)
            BUILD_TARGET=i686-w64-mingw32
            export WINEPATH=$("$PROJECT_DIR"/winepath-for $BUILD_TARGET)
            ;;
        x86_64-darwin-brew-gcc10-*)
            BUILD_TARGET=x86_64-darwin-brew-gcc10
            ;;
        x86_64-darwin*)
            BUILD_TARGET=x86_64-darwin
            ;;
        arm64-darwin*)
            BUILD_TARGET=x86_64-darwin
            ;;
        *)
            echo "Failed to recognize target platform: $target"
            echo "Possible targets:"
            show_toolchains
            exit 1
            ;;
    esac
    if [ -z "${TOOLCHAIN_FILE+x}" ] && [ -r "$PROJECT_DIR/cmake/toolchain/${BUILD_TARGET}.cmake" ]; then
        export CMAKE_TOOLCHAIN_FILE="$PROJECT_DIR/cmake/toolchain/${BUILD_TARGET}.cmake"
    fi
    CMAKE_BUILD_TYPE=Release "$PROJECT_DIR/getlibs.sh" "$BUILD_TARGET"
    export CMAKE_PREFIX_PATH="$PROJECT_DIR/local/$BUILD_TARGET"
    BUILD_EXTRA="-DFIND_FATAL=ON ${BUILD_EXTRA}"
    case "$target" in
        *-ubsan*)
            BUILD_SUFFIX="${BUILD_SUFFIX}-ubsan"
            BUILD_EXTRA="-DUBSAN=ON ${BUILD_EXTRA}"
            ;;
    esac
    case "$target" in
        *-asan*)
            BUILD_SUFFIX="${BUILD_SUFFIX}-asan"
            BUILD_EXTRA="-DASAN=ON ${BUILD_EXTRA}"
            ;;
    esac
    case "$target" in
        *-lsan*)
            BUILD_SUFFIX="${BUILD_SUFFIX}-lsan"
            BUILD_EXTRA="-DLSAN=ON ${BUILD_EXTRA}"
            ;;
    esac
    case "$target" in
        *-debug)
            export CMAKE_BUILD_TYPE=Debug
            ;;
        *-release)
            export CMAKE_BUILD_TYPE=Release
            ;;
        *)
            if [ -z "${CMAKE_BUILD_TYPE+x}" ]; then
                export CMAKE_BUILD_TYPE=Debug
            fi
    esac
    BUILD_DIR="build-${BUILD_TARGET}${BUILD_SUFFIX}-${CMAKE_BUILD_TYPE,,}"
    echo "COMPILE for $target in $BUILD_DIR using $BUILD_EXTRA"
    show_cmake_vars
    cmake -S "$PROJECT_DIR" -B "$BUILD_DIR" $BUILD_EXTRA
    cmake --build "$BUILD_DIR" --config $CMAKE_BUILD_TYPE
    (cd "$BUILD_DIR" ; ctest -C $CMAKE_BUILD_TYPE --output-on-failure)
    echo "The following can be used to install the library into \$SOME_PREFIX_PATH:"
    echo "cmake --install $BUILD_DIR --config $CMAKE_BUILD_TYPE --prefix \$SOME_PREFIX_PATH"
    echo "COMPILE $target success!"
done
