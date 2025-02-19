#!/bin/bash

set -e
set -x

THIS_DIR="$PWD"

# Check Autoconf version
REQUIRED_AUTOCONF_VERSION=2.71
AUTOCONF_VERSION=$(autoconf --version | grep -oP '\d+\.\d+\.\d+' | head -n 1)

if [[ "$(printf '%s\n' "$REQUIRED_AUTOCONF_VERSION" "$AUTOCONF_VERSION" | sort -V | head -n1)" != "$REQUIRED_AUTOCONF_VERSION" ]]; then
    echo "Error: Autoconf version $REQUIRED_AUTOCONF_VERSION or higher is required."
    exit 1
fi

PYVER=3.11.0
SRCDIR=src/Python-$PYVER

COMMON_ARGS="--arch ${ARCH:-arm} --api ${ANDROID_API:-23}"

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
