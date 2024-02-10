#!/bin/bash

set -e
trap 'rm -rf build' EXIT

BIN_NAME="zsign"
DEBUG=0
BUILD_DIR="build"
COMPILE_COMMANDS_FILE="compile_commands.json"

function ensure_installed() {
	if ! [ -x "$(command -v $1)" ]; then
		echo "Error: $1 is not installed." >&2
		exit 1
	fi
}

for arg in "$@"; do
	if [ "$arg" == "-d" ]; then
		DEBUG=1
	fi
done

ensure_installed make
ensure_installed cmake

if [ $DEBUG -eq 1 ]; then
	ensure_installed bear
	echo "Debug build..."
	rm -rf $BUILD_DIR && mkdir -p $BUILD_DIR && rm -f $BIN_NAME && rm -f $COMPILE_COMMANDS_FILE && pushd $BUILD_DIR
	bear -- cmake -DCMAKE_BUILD_TYPE=Debug ..
	bear -- make -j$(nproc)
	mv $COMPILE_COMMANDS_FILE ..
	mv $BIN_NAME ..
	popd
	exit 0
fi

echo "Building..."
rm -rf $BUILD_DIR && mkdir -p $BUILD_DIR && rm -f $BIN_NAME && pushd $BUILD_DIR
cmake ..
make -j$(nproc)
mv $BIN_NAME ..
popd