FROM fedora:latest
WORKDIR /build

# FIXME: Need this?
# RUN dnf update -y

# Install required packages:
#
#  buildsystem: cmake gcc gcc-g++ make
#  Gauche: autoconf automake
#  NMosh: gmp-devel oniguruma-devel
#  Guile: libtool flex gettext-devel pkgconfig libunistring-devel libffi-devel
#         gc-devel
#  Vicare: texinfo
RUN dnf install -y make cmake gcc gcc-c++ autoconf automake gmp-devel oniguruma-devel libtool flex gettext-devel pkgconfig libunistring-devel libffi-devel gc-devel texinfo
