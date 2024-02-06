#!/bin/bash

# Exit on error
set -e
trap 'rm -rf build' EXIT

# This script is used to build the project
BIN_NAME="zsign"

# Check if cmake is installed
if ! [ -x "$(command -v cmake)" ]; then
  echo 'Error: cmake is not installed.' >&2
#   exit 1
fi

rm -rf build && rm -f $BIN_NAME && mkdir -p build && pushd build
cmake ..
make -j$(nproc)
mv $BIN_NAME ..
popd