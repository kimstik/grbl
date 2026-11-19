#!/bin/sh
# Build an AVR toolchain from a GCC weekly snapshot into $1.
# Configure options follow ZakKemble/avr-gcc-build, limited to C.
#   usage: build-avr-gcc.sh <prefix> <gcc snapshot, e.g. 17-20261115>
set -eu
PREFIX=$1
GCC=gcc-$2
BINUTILS=binutils-2.47
LIBC=avr-libc-2.3.2
JOBS=$(nproc)
export PATH="$PREFIX/bin:$PATH"

cd "$(mktemp -d)"
curl -fsSL "https://ftpmirror.gnu.org/binutils/$BINUTILS.tar.xz" | tar -xJ
curl -fsSL "https://gcc.gnu.org/pub/gcc/snapshots/$2/$GCC.tar.xz" | tar -xJ
curl -fsSL "https://github.com/avrdudes/avr-libc/releases/download/avr-libc-2_3_2-release/$LIBC.tar.bz2" | tar -xj

mkdir binutils-obj gcc-obj
(cd binutils-obj && ../$BINUTILS/configure --prefix="$PREFIX" --target=avr --disable-nls --disable-werror \
    && make -j"$JOBS" && make install-strip)
(cd gcc-obj && ../$GCC/configure --prefix="$PREFIX" --target=avr --enable-languages=c --disable-nls \
    --disable-libssp --disable-libada --with-dwarf2 --disable-shared --enable-static --enable-plugin \
    --with-gnu-as --with-gnu-ld --without-zstd \
    && make -j"$JOBS" && make install-strip)
(cd $LIBC && ./configure --prefix="$PREFIX" --host=avr --build="$(./config.guess)" \
    && make -j"$JOBS" && make install)
