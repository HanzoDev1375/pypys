patch -F0 -p1 -i "${FILESDIR}/check-crypt.patch"
patch -F0 -p1 -i "${FILESDIR}/gdbm.patch"
patch -F0 -p1 -i "${FILESDIR}/decimal.patch"
patch -F0 -p1 -i "${FILESDIR}/ncurses-headers.patch"
patch -F0 -p1 -i "${FILESDIR}/android-locale-utf8.patch"
patch -F0 -p1 -i "${FILESDIR}/fix-cross-modules.patch"

mkdir build-target
