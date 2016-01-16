FROM ubuntu:14.04
WORKDIR /build

# FIXME: We sometimes need this for GCC
RUN apt-get update

# Install required packages:
#
#  buildsystem: cmake gcc g++
#  Gauche: autoconf automake
#  NMosh: libgmp-dev libonig-dev
#  Guile: libtool flex gettext pkg-config libunistring-dev libffi-dev libgc-dev
#  Chicken: time (avoid bashism)
#  Vicare: texinfo
RUN apt-get install -y cmake gcc g++ autoconf automake libgmp-dev libonig-dev libtool flex gettext pkg-config libunistring-dev libffi-dev libgc-dev time texinfo


