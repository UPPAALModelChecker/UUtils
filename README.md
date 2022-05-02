# UUtils
Library for miscellaneous utilities used in [UDBM](https://github.com/UPPAALModelChecker/UDBM), [UCDD](https://github.com/UPPAALModelChecker/UCDD) and others.

## Dependencies
This repository depends on `cmake gcc xxHash doctest boost`.
## Build on Linux
To build, test, and install the project, run the following commands:
```sh
git clone https://github.com/UPPAALModelChecker/UUtils
cd UUtils
./getlibs.sh all
cmake -S . -B build -DTESTING=yes
cmake --build build
(cd build ; ctest)
sudo cmake --install build
```

## Build on Linux for Windows (cross-compile)
```sh
git clone https://github.com/UPPAALModelChecker/UUtils
cd UUtils
CMAKE_TOOLCHAIN_FILE="$(pwd)/toolchains/mingw.cmake" ./getlibs.sh all
cmake -S . -B build -DTESTING=yes -DCMAKE_TOOLCHAIN_FILE="$(pwd)/toolchains/mingw.cmake" 
cmake --build build
(cd build ; ctest)
sudo cmake --install build
```
