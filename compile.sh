#!/usr/bin/env bash
set -e

if [ $# -eq 0 ] ; then
  echo "Script $0 compiles this library for a set of targets specified as arguments."
  echo "Possible arguments:"
  echo "  linux64-release linux64-debug linux64-libs-release linux64-libs-debug"
  echo "  win64-release win64-debug win64-libs-release win64-libs-debug"
  echo "  macos64-release macos64-debug macos64-libs-release macos64-libs-debug"
  echo "linux* targets are compiled on Linux assuming cmake, ninja/make, gcc and g++ installed."
  echo "win* targets are cross-compiled on Linux assuming cmake, ninja/make, MinGW and Wine installed."
  echo "macos* targets are compiled on MacOS assuming cmake, ninja/make, gcc and g++ are installed."
  echo "For targets with 'lib' in their name script will call getlibs to build the dependencies in advance."
  echo "The script is sensitive to CMAKE_BUILD_TYPE and other environment variables"
  exit 1
fi

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for target in "$@" ; do
    unset CMAKE_TOOLCHAIN_FILE
    unset CMAKE_PREFIX_PATH
    unset CMAKE_BUILD_TYPE
    unset BUILD_TARGET
    unset BUILD_SUFFIX
    unset BUILD_EXTRA
    case "$target" in
        linux64*)
            BUILD_TARGET=linux64
            ;;
        macos*)
            BUILD_TARGET=macos64
            ;;
        win64*)
            BUILD_TARGET=win64
            export CMAKE_TOOLCHAIN_FILE="$PROJECT_DIR/toolchains/mingw.cmake"
	    if [ -z "$WINEPATH" ]; then
		export WINEPATH=$("$PROJECT_DIR/mingw-winepath.sh")
	    fi
            ;;
        *)
            echo "Failed to recognize target platform: $target"
            exit 1
            ;;
    esac
    case "$target" in
        *lib*)
	    CMAKE_BUILD_TYPE=Release "$PROJECT_DIR/getlibs.sh" "$BUILD_TARGET"
            export CMAKE_PREFIX_PATH="$PROJECT_DIR/libs-$BUILD_TARGET"
            BUILD_SUFFIX="-libs"
	    BUILD_EXTRA="-DFIND_FATAL=ON ${BUILD_EXTRA}"
            ;;
    esac
    case "$target" in
        *debug)
            export CMAKE_BUILD_TYPE=Debug
            ;;
        *release)
            export CMAKE_BUILD_TYPE=Release
            BUILD_EXTRA="-DUUtils_WITH_BENCHMARKS=ON $BUILD_EXTRA"
            ;;
        *)
            echo "Failed to recognize build type: $target"
            echo "Using Debug instead"
            export CMAKE_BUILD_TYPE=Debug
    esac
    BUILD_DIR="build-${BUILD_TARGET}${BUILD_SUFFIX}-${CMAKE_BUILD_TYPE,,}"
    echo "COMPILE for $target in $BUILD_DIR using $BUILD_EXTRA"
    echo "  CMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE:-(unset)}"
    echo "  CMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH:-(unset)}"
    echo "  CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE:-(unset)}"
    cmake -S "$PROJECT_DIR" -B "$BUILD_DIR" $BUILD_EXTRA
    cmake --build "$BUILD_DIR" --config $CMAKE_BUILD_TYPE
    (cd "$BUILD_DIR" ; ctest -C $CMAKE_BUILD_TYPE --output-on-failure)
    echo "COMPILE $target success!"
done
