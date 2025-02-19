#!/bin/bash

set -e
set -x

THIS_DIR="$PWD"

PYVER=3.12.9
SRCDIR=src/Python-$PYVER

COMMON_ARGS="--arch ${ARCH:-arm} --api ${ANDROID_API:-28}"

# Function to install xz if not installed
install_xz() {
    if command -v apt &> /dev/null; then
         apt update &&  apt-get install -y xz-utils
    elif command -v yum &> /dev/null; then
        ## yum install -y xz
    elif command -v dnf &> /dev/null; then
         ##dnf install -y xz
    elif command -v pacman &> /dev/null; then
        ## pacman -S --noconfirm xz
    else
        echo "xz is not installed and no supported package manager found. Please install xz-utils manually."
        exit 1
    fi
}

# Check if xz is installed
if ! command -v xz &> /dev/null; then
    echo "xz is not installed. Installing xz..."
    install_xz
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
