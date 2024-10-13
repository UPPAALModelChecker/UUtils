# UUtils
Library for miscellaneous utilities used in [UDBM](https://github.com/UPPAALModelChecker/UDBM), [UCDD](https://github.com/UPPAALModelChecker/UCDD) and others.

## Dependencies
UUtils depend on tools like `git`, `cmake`, `ninja`/`make` and a compiler installed:
```shell
sudo apt-get -y install git cmake ninja-build make gcc g++
```
UUtils also depends on libraries `xxHash`, `doctest`, `benchmark`, `boost`, which can be preinstalled using [getlibs.sh](getlibs.sh) script or just run the build commands bellow where `cmake` will download and compile the libraries on demand.

## Build, Test and Install
```shell
git clone https://github.com/UPPAALModelChecker/UUtils
cmake -S UUtils -B build
cmake --build build
ctest --test-dir build --output-on-failure
sudo cmake --install build
```
That's it!

To compile for multiple targets while reusing dependencies use [compile.sh](compile.sh) script:
```shell
git clone https://github.com/UPPAALModelChecker/UUtils
./UUtils/compile.sh linux64-libs-release linux64-libs-debug win64-libs-release win64-libs-debug
```
