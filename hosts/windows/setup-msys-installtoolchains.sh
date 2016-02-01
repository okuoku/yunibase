#!/bin/sh

pacman --noconfirm --needed -Sy \
    mingw-w64-i686-binutils mingw-w64-i686-crt-git mingw-w64-i686-gcc \
    mingw-w64-i686-gcc-libs mingw-w64-i686-headers-git \
    mingw-w64-i686-libmangle-git mingw-w64-i686-tools-git \
    mingw-w64-x86_64-binutils mingw-w64-x86_64-crt-git mingw-w64-x86_64-gcc \
    mingw-w64-x86_64-gcc-libs mingw-w64-x86_64-headers-git \
    mingw-w64-x86_64-libmangle-git mingw-w64-x86_64-tools-git
