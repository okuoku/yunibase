FROM i386/ubuntu:xenial
WORKDIR /build

# Install required packages:
#
#  buildsystem: cmake gcc g++
#  Gauche: autoconf automake
#  NMosh: libgmp-dev libonig-dev
#  Guile: libtool flex gettext pkg-config libunistring-dev libffi-dev libgc-dev
#  Chicken: time (avoid bashism)
#  Vicare: texinfo
#  Larceny: nasm
#  Chez: ncurses x11 libc6-dev-i386
RUN apt-get update && apt-get install -y \
cmake gcc g++ \
autoconf automake \
libgmp-dev libonig-dev \
libtool flex gettext pkg-config libunistring-dev libffi-dev libgc-dev \
time texinfo nasm \
ncurses-dev libx11-dev g++-multilib

# 32bitness
RUN mv /bin/uname /bin/uname.orig && \
echo '#!/bin/sh\n' 'exec linux32 uname.orig $*' > /bin/uname && \
chmod +x /bin/uname
