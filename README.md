# UUtils
The spookiest utility library

This is a utility library used in [UDBM](https://github.com/UPPAALModelChecker/UDBM) and [UCDD](https://github.com/UPPAALModelChecker/UCDD)

## Dependencies
This repository depends on `cmake gcc xxHash doctest boost`.
## Build
To build, test, and install the project, run the following commands:
```sh
git clone https://github.com/UPPAALModelChecker/UUtils
cd UUtils
mkdir bulid
cd build
cmake -DTESTING=yes ..
make
ctest
sudo make install
```
