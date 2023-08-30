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
    echo "COMPILE for $target"
    BUILD_TYPE=""
    BUILD_TARGET=""
    BUILD_SUFFIX=""
    CMAKE_TOOLCHAIN_FILE=""
    BUILD_TOOLCHAIN=""
    BUILD_PREFIX=""
    BULD_EXTRA=""
    case "$target" in
        linux64*)
            BUILD_TARGET=linux64
            ;;
        macos*)
            BUILD_TARGET=macos64
            ;;
        win64*)
            BUILD_TARGET=win64
            CMAKE_TOOLCHAIN_FILE="$PROJECT_DIR/toolchains/mingw.cmake"
            BUILD_TOOLCHAIN="-DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}"
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
            BUILD_PREFIX="-DCMAKE_PREFIX_PATH=$PROJECT_DIR/libs-$BUILD_TARGET"
            BUILD_SUFFIX="-libs"
	    if [ -n "$CMAKE_TOOLCHAIN_FILE" ]; then
		CMAKE_TOOLCHAIN_FILE="$CMAKE_TOOLCHAIN_FILE" CMAKE_BUILD_TYPE=Release "$PROJECT_DIR/getlibs.sh" "$BUILD_TARGET"
	    else
		CMAKE_BUILD_TYPE=Release "$PROJECT_DIR/getlibs.sh" "$BUILD_TARGET"
	    fi
	    BUILD_EXTRA="-DFIND_FATAL=ON ${BUILD_EXTRA}"
            ;;
    esac
    case "$target" in
        *debug)
            BUILD_TYPE=Debug
            ;;
        *release)
            BUILD_TYPE=Release
            BUILD_EXTRA="-DUUtils_WITH_BENCHMARKS=ON $BUILD_EXTRA"
            ;;
        *)
            echo "Failed to recognize build type: $target"
            echo "Using Debug instead"
            BUILD_TYPE=Debug
    esac
    BUILD_DIR="build-${BUILD_TARGET}${BUILD_SUFFIX}-${BUILD_TYPE,,}"
    cmake -B "$BUILD_DIR" "$BUILD_PREFIX" "$BUILD_TOOLCHAIN" -DCMAKE_BUILD_TYPE=$BUILD_TYPE $BUILD_EXTRA -S "$PROJECT_DIR"
    cmake --build "$BUILD_DIR" --config $BUILD_TYPE
    (cd "$BUILD_DIR" ; ctest -C $BUILD_TYPE --output-on-failure)
    echo "COMPILE $target success!"
done
