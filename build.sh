#!/bin/bash

set -e
set -x

THIS_DIR="$PWD"

PYVER=3.12.9
SRCDIR=src/Python-$PYVER

COMMON_ARGS="--arch ${ARCH:-arm} --api ${ANDROID_API:-28}"

# Check if xz is installed
if ! command -v xz &> /dev/null; then
    echo "xz is not installed. Please install xz-utils."
    exit 1
fi

if [ ! -d $SRCDIR ]; then
    mkdir -p src
    pushd src
    curl -vLO https://www.python.org/ftp/python/$PYVER/Python-$PYVER.tar.xz
    tar --no-same-owner -xf Python-$PYVER.tar.xz
    popd
fi

cp -r Android $SRCDIR
pushd $SRCDIR
patch -Np1 -i ./Android/unversioned-libpython.patch
autoreconf -ifv
./Android/build_deps.py $COMMON_ARGS
./Android/configure.py $COMMON_ARGS --prefix=/usr "$@"
make
make install DESTDIR="$THIS_DIR/build"
popd
cp -r $SRCDIR/Android/sysroot/usr/share/terminfo build/usr/share/
cp devscripts/env.sh build/
