FROM fedora:latest
WORKDIR /build

# Install required packages:
#
#  buildsystem: cmake gcc gcc-g++ make
#  Gauche: autoconf automake
#  NMosh: gmp-devel oniguruma-devel
#  Guile: libtool flex gettext-devel pkgconfig libunistring-devel libffi-devel
#         gc-devel libtool-ltdl-devel
#  Vicare: texinfo
#  Sagittarius: zlib-devel openssl-devel
#  Chez: ncurses x11 libuuid-devel
RUN dnf install -y make cmake gcc gcc-c++ autoconf automake gmp-devel oniguruma-devel libtool flex gettext-devel pkgconfig libunistring-devel libffi-devel gc-devel libtool-ltdl-devel texinfo zlib-devel \
ncurses-devel libX11-devel openssl-devel libuuid-devel

