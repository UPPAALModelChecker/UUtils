#/usr/bin/env bash
# This script prints WINEPATH to include MINGW and GCC runtime environments,
# so that libwinpthread-1.dll, libgcc_s_seh-1.dll etc are available everywhere.

set -e

if [ -z "$(command -v x86_64-w64-mingw32-g++)" ]; then
    echo "Failed to find a cross-compiler x86_64-w64-mingw32-g++"
    echo "Please install mingw-w64-x86-64-dev"
    exit 1
fi

if [ -z "$(command -v winepath)" ]; then
    echo "Failed to find a winepath"
    echo "Please install wine with winepath"
    exit 1
fi

GCC_S_FILE=$(x86_64-w64-mingw32-g++ --print-file-name libgcc_s.a)
GCC_S_FILE=$(realpath "$GCC_S_FILE")
GCC_RUNTIME_PATH=$(dirname "$GCC_S_FILE")
GCC_RUNTIME_WINEPATH=$(winepath --windows "$GCC_RUNTIME_PATH")

WINPTHREAD_FILE=$(x86_64-w64-mingw32-g++ --print-file-name libwinpthread-1.dll)
WINPTHREAD_FILE=$(realpath "$WINPTHREAD_FILE")
MINGW_RUNTIME_PATH=$(dirname "$WINPTHREAD_FILE")
MINGW_RUNTIME_WINEPATH=$(winepath --windows "$MINGW_RUNTIME_PATH")

echo "${GCC_RUNTIME_WINEPATH};${MINGW_RUNTIME_WINEPATH}"
