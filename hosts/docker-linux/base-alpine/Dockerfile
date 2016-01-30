FROM alpine:edge
WORKDIR /build

# Install required packages:
#
#  buildsystem: cmake gcc gcc-g++ make
#  Gauche: autoconf automake
#  NMosh: gmp-dev oniguruma-dev
#  Guile: libtool libltdl gettext-dev pkgconfig libffi-dev
#         gc-dev
#         MISSING: unistring
#  Vicare: texinfo
#  Sagittarius: zlib-dev
RUN echo http://dl-4.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories
RUN apk update && apk add \
cmake gcc g++ make \
autoconf automake \
gmp-dev oniguruma-dev \
libtool libltdl gettext-dev pkgconfig libffi-dev gc-dev \
texinfo \
zlib-dev
