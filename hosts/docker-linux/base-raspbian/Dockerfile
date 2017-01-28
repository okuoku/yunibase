# qemu-user should be resigered with binfmt_misc
#
# docker run --rm --privileged multiarch/qemu-user-static:register --reset

FROM resin/rpi-raspbian
WORKDIR /build

# Install required packages:
#
#  Raspbian: make
#  buildsystem: cmake gcc g++
#  Gauche: autoconf automake
#  NMosh: libgmp-dev libonig-dev
#  Guile: libtool flex gettext pkg-config libunistring-dev libffi-dev libgc-dev
#  Chicken: time (avoid bashism)
#  Vicare: texinfo
#  Chez: ncurses x11
#  Sagittarius: zlib1g-dev
RUN apt-get update && apt-get install -y \
make cmake gcc g++ \
autoconf automake \
libgmp-dev libonig-dev \
libtool flex gettext pkg-config libunistring-dev libffi-dev libgc-dev \
time texinfo \
ncurses-dev libx11-dev zlib1g-dev
