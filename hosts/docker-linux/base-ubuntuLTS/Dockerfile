FROM ubuntu:18.04
WORKDIR /build

# Install required packages:
#
#  buildsystem: cmake gcc g++
#  Gauche: autoconf automake
#  NMosh: libgmp-dev libonig-dev
#  Guile: libtool flex gettext pkg-config libunistring-dev libffi-dev libgc-dev
#  Chicken: time (avoid bashism)
#  Vicare: texinfo
#  Chez: ncurses x11 uuid-dev
#  Sagittarius: zlib1g-dev libssl-dev
RUN apt-get update && apt-get install -y \
cmake gcc g++ \
autoconf automake \
libgmp-dev libonig-dev \
libtool flex gettext pkg-config libunistring-dev libffi-dev libgc-dev \
time texinfo \
ncurses-dev libx11-dev zlib1g-dev libssl-dev uuid-dev
