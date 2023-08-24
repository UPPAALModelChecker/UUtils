# UUtils
Library for miscellaneous utilities used in [UDBM](https://github.com/UPPAALModelChecker/UDBM), [UCDD](https://github.com/UPPAALModelChecker/UCDD) and others.

## Dependencies
This repository depends on `cmake gcc g++ xxHash doctest benchmark boost`.
## Build, Test and Install
```shell
git clone https://github.com/UPPAALModelChecker/UUtils
cmake -B build -S UUtils -DCMAKE_BUILD_TYPE=Release -DUUtils_WITH_TESTS=ON -DUUtils_WITH_BENCHMARK=ON
cmake --build build
(cd build ; ctest)
sudo cmake --install build
```

```shell
cd UUtils
./getlibs.sh all
cmake -S . -B build -DTESTING=yes
cmake --build build
(cd build ; ctest)
sudo cmake --install build
```

## Cross-Compile for Windows on Linux
```sh
git clone https://github.com/UPPAALModelChecker/UUtils
cd UUtils
CMAKE_TOOLCHAIN_FILE="$(pwd)/toolchains/mingw.cmake" ./getlibs.sh all
cmake -S . -B build -DTESTING=yes -DCMAKE_TOOLCHAIN_FILE="$(pwd)/toolchains/mingw.cmake" 
cmake --build build
(cd build ; ctest)
sudo cmake --install build
```
