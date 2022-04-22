FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /build

# Install required packages:
#
#  buildsystem: cmake gcc g++
#  Gauche: autoconf automake
#  NMosh: libgmp-dev libonig-dev
#  Guile: libtool flex gettext pkg-config libunistring-dev libffi-dev libgc-dev
#         autopoint gperf
#  Chicken: time (avoid bashism)
#  Vicare: texinfo
#  Chez: ncurses x11 uuid-dev
#  Sagittarius: zlib1g-dev libssl-dev
#  Cyclone: libck-dev
#  Digamma: cpio (and, LLVM latest stable)
#  Bigloo: patch libpcre3-dev libpcre2-dev
#  Kawa: openjdk-8-jdk-headless
#  Racket: libcairo2-dev libpango1.0-dev (for doc)
ADD https://apt.llvm.org/llvm.sh /
RUN chmod +x /llvm.sh
RUN apt-get update && apt-get install -y \
cmake gcc g++ \
autoconf automake \
libgmp-dev libonig-dev \
libtool flex gettext pkg-config libunistring-dev libffi-dev libgc-dev \
time texinfo \
ncurses-dev libx11-dev zlib1g-dev libssl-dev uuid-dev libck-dev cpio libpcre3-dev libpcre2-dev \
openjdk-8-jdk-headless \
wget lsb-release software-properties-common autopoint gperf libcairo2-dev \
libpango1.0-dev patch \
&& /llvm.sh 10
