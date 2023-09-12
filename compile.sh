#!/usr/bin/env bash
set -e

if [ $# -eq 0 ] ; then
  echo "Script $0 compiles this library for a set of targets specified as arguments."
  echo "Possible targets:"
  echo "  linux64|x86_64-linux - targets are compiled on Linux assuming cmake, ninja/make, gcc and g++ installed."
  echo "  win64|x86_64-w64-mingw32 - targets are cross-compiled on Linux assuming cmake, ninja/make, MinGW and Wine installed."
  echo "  macos64|x86_64-darwin - targets are compiled on MacOS assuming cmake, ninja/make, gcc and g++ are installed."
  echo "Possible target suffixes (append to the target making one word):"
  echo "  -libs - build with dependent libraries to be installed by getlib.sh"
  echo "  -ubsan - build with undefined behavior sanitizer (may break benchmarks with g++-13)"
  echo "  -lsan - build with memory leak sanitizer (expect test_new to fail as it leaks on purpose)"
  echo "  -asan - build with address sanitizer (expect test_new to fail as it leaks on purpose)"
  echo "  -debug/-release - build either with debug information or optimized for release"
  echo "For example, build linux64 release with getlibs and undefined behavior sanitizer:"
  echo "  $0 linux64-libs-ubsan-release"
  echo "The script is sensitive to CMAKE_BUILD_TYPE and other environment variables"
  machine=$(uname -m)
  kernel=$(uname -s)
  targets="${machine,,}-${kernel,,}-libs-release"
  if [ -n "$(command -v x86_64-w64-mingw32-g++)" ]; then
    targets="$targets x86_64-w64-mingw32-libs-release"
  fi
  echo "Guessing: $targets"
else
  targets="$@"
fi

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for target in $targets ; do
    unset CMAKE_TOOLCHAIN_FILE
    unset CMAKE_PREFIX_PATH
    unset CMAKE_BUILD_TYPE
    unset BUILD_TARGET
    unset BUILD_SUFFIX
    unset BUILD_EXTRA
    case "$target" in
        linux64-gcc10*|x86_64-linux-gcc10*)
            BUILD_TARGET=x86_64-linux-gcc10
            ;;
        linux64*|x86_64-linux*)
            BUILD_TARGET=x86_64-linux
            ;;
        linux32-gcc10*|i686-linux-gcc10*)
            BUILD_TARGET=i686-linux-gcc10
            ;;
        linux32*|i686-linux*)
            BUILD_TARGET=i686-linux
            ;;
        win64*|x86_64-w64-mingw32*)
            BUILD_TARGET=x86_64-w64-mingw32
            [ -n "$WINEPATH" ] || export WINEPATH=$("$PROJECT_DIR"/winepath-for $BUILD_TARGET)
            ;;
        win32*|i686-w64-mingw32*)
            BUILD_TARGET=i686-w64-mingw32
            [ -n "$WINEPATH" ] || export WINEPATH=$("$PROJECT_DIR"/winepath-for $BUILD_TARGET)
            ;;
        macos64-brew-gcc10-*|darwin-brew-gcc10-*|x86_64-darwin-brew-gcc10-*)
            BUILD_TARGET=x86_64-darwin-brew-gcc10
            ;;
        macos*|darwin*|x86_64-darwin*)
            BUILD_TARGET=x86_64-darwin
            ;;
        *)
            echo "Failed to recognize target platform: $target"
            exit 1
            ;;
    esac
    [ -z "$BUILD_TARGET" ] || export CMAKE_TOOLCHAIN_FILE="$PROJECT_DIR/cmake/toolchain/${BUILD_TARGET}.cmake"
    case "$target" in
        *-lib*)
            CMAKE_BUILD_TYPE=Release "$PROJECT_DIR/getlibs.sh" "$BUILD_TARGET"
            export CMAKE_PREFIX_PATH="$PROJECT_DIR/local/$BUILD_TARGET"
            BUILD_SUFFIX="-libs"
            BUILD_EXTRA="-DFIND_FATAL=ON ${BUILD_EXTRA}"
            ;;
    esac
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
            if [ -z "$CMAKE_BUILD_TYPE" ]; then
                export CMAKE_BUILD_TYPE=Debug
            fi
    esac
    BUILD_DIR="build-${BUILD_TARGET}${BUILD_SUFFIX}-${CMAKE_BUILD_TYPE,,}"
    echo "COMPILE for $target in $BUILD_DIR using $BUILD_EXTRA"
    echo "  CMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE:-(unset)}"
    echo "  CMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH:-(unset)}"
    echo "  CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE:-(unset)}"
    echo "  CMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX:-(unset)}"
    cmake -S "$PROJECT_DIR" -B "$BUILD_DIR" $BUILD_EXTRA
    cmake --build "$BUILD_DIR" --config $CMAKE_BUILD_TYPE
    (cd "$BUILD_DIR" ; ctest -C $CMAKE_BUILD_TYPE --output-on-failure)
    echo "The following can be used to install the library into \$SOME_PREFIX_PATH:"
    echo "cmake --install $BUILD_DIR --config $CMAKE_BUILD_TYPE --prefix \$SOME_PREFIX_PATH"
    echo "COMPILE $target success!"
done
